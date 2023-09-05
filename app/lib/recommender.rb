# frozen_string_literal: true

class Recommender
  MINIMUM_SCORE = 0.5

  attr_reader :scores

  def initialize(*)
    @scores = self.class.combine_scores(*)
  end

  def self.combine_scores(*args)
    args.each.with_object({}) do |arg, scores|
      arg.each do |entity, items|
        scores[entity] ||= {}
        items.each do |item, score|
          scores[entity][item] ||= 0
          scores[entity][item] += score
        end
      end
    end
  end

  def recommended_items(entity)
    return [] if scores.empty?

    (scores[entity].to_a + Pearson.recommendations(scores, entity))
      .reject { |rec| rec[1] <= MINIMUM_SCORE }
      .sort_by { |rec| -rec[1] }
      .first(10)
      .map(&:first)
  end
end
