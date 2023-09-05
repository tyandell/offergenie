# frozen_string_literal: true

class Rating < ApplicationRecord
  validates :demographic_key, inclusion: Demographic.keys
  validates :keyword, presence: true
  validates :value, numericality: { only_integer: true, other_than: 0 }

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

  def demographic
    Demographic.from_key!(demographic_key)
  end
end
