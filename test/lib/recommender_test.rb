# frozen_string_literal: true

require "test_helper"

class RecommenderTest < ActiveSupport::TestCase
  test "combine_scores" do
    scores1 = { "A" => { "X" => 1, "Y" => 2 }, "B" => { "X" => 1 } }
    scores2 = { "A" => { "X" => 1, "Z" => 2 }, "C" => { "X" => 1 } }
    result = Recommender.combine_scores(scores1, scores2)
    assert_equal({ "A" => { "X" => 2, "Y" => 2, "Z" => 2 }, "B" => { "X" => 1 }, "C" => { "X" => 1 } }, result)
  end
end
