# frozen_string_literal: true

require "test_helper"

class DemographicTest < ActiveSupport::TestCase
  test "parse_age_range with invalid age range" do
    assert_raises Demographic::Error do
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
end
