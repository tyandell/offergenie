# frozen_string_literal: true

require "test_helper"

class DemographicTest < ActiveSupport::TestCase
  test "keys" do
    assert_equal Demographic::AGE_RANGES.count * Demographic::GENDERS.count, Demographic.keys.count
  end

  test "from_key" do
    demographic = Demographic.from_key("18-24 male")
    assert demographic.valid?

    demographic = Demographic.from_key("18-100 other")
    assert_not demographic.valid?
  end

  test "from_key!" do
    assert_raises ActiveModel::ValidationError do
      Demographic.from_key! "18-100 other"
    end
  end

  test "include_age?" do
    assert Demographic.from_key!("18-24 male").include_age?(18)
    assert Demographic.from_key!("18-24 male").include_age?(24)
    assert_not Demographic.from_key!("18-24 male").include_age?(25)
  end

  test "parse_age_range with invalid age range" do
    assert_raises Demographic::ParseError do
      Demographic.parse_age_range "18-100"
    end
  end

  test "parse_age_range with normal age range" do
    range = Demographic.parse_age_range "18-24"
    assert range.include?(18)
    assert range.include?(24)
    assert range.include?(24.9)
    assert_not range.include?(25)
  end

  test "parse_age_range with last age range" do
    range = Demographic.parse_age_range "90+"
    assert range.include?(90)
    assert range.include?(100)
    assert range.include?(1000)
  end

  test "age_range_for_age" do
    assert_equal "18-24", Demographic.age_range_for_age(18)
    assert_equal "18-24", Demographic.age_range_for_age(24)
    assert_equal "90+", Demographic.age_range_for_age(100)
    assert_nil Demographic.age_range_for_age(0)
  end
end
