# frozen_string_literal: true

require "test_helper"

class RatingTest < ActiveSupport::TestCase
  test "factory" do
    assert FactoryBot.build(:rating).valid?
  end

  test "scores" do
    FactoryBot.create_list :rating, 100

    expected = Rating.sum(:value)

    actual = 0
    Rating.scores.each do |_demographic_key, keywords|
      keywords.each do |_keyword, score|
        actual += score
      end
    end

    assert_equal expected, actual
  end
end
