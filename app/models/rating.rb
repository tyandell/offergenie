# frozen_string_literal: true

# A score value for a demographic and keyword pair.
#
# This is used to store the scores that are used by {Recommender} to determine
# the best keywords for a given demographic. This could also be used to
# implement like and dislike buttons.
class Rating < ApplicationRecord
  validates :demographic_key, inclusion: Demographic.keys
  validates :keyword, presence: true
  validates :value, numericality: { only_integer: true, other_than: 0 }

  # Returns scores used by {Recommender}.
  def self.scores
    results = {}
    select(:demographic_key, :keyword, "sum(value) as score")
      .group(:demographic_key, :keyword)
      .order(score: :desc)
      .each do |rating|
        results[rating.demographic_key] ||= {}
        results[rating.demographic_key][rating.keyword] = rating.score
      end
    results
  end

  # Returns the {Demographic} instance for +demographic_key+.
  #
  # @return [Demographic]
  def demographic
    Demographic.from_key!(demographic_key)
  end
end
