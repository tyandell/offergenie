# frozen_string_literal: true

module OfferRecommendation
  extend ActiveSupport::Concern

  DEMOGRAPHIC_BOOST = 10

  NEW_BOOST = 10
  NEW_BOOST_PERIOD = 15.minutes

  included do
    scope :recommended_for, ->(user) {
      select("offers.*", recommendation_score_select_sql(user))
        .order(recommendation_score: :desc)
    }
  end

  class_methods do
    def recommender
      Recommender.new(Activation.scores, Rating.scores)
    end

    def recommended_keywords_for(user)
      recommender.recommended_items(user.demographic.key)
    end

    def recommendation_score_select_sql(user)
      keywords = recommended_keywords_for(user).join(" ")

      params = [
        keywords,
        user.demographic.age_range, user.demographic.gender,
        NEW_BOOST_PERIOD.ago
      ]
      sanitize_sql([<<~SQL.squish, *params])
        (
          word_similarity(?, keywords) +
          case when age_range = ? and gender = ? then #{DEMOGRAPHIC_BOOST} else 0 end +
          case when offers.created_at > ? then #{NEW_BOOST} else 0 end
        ) as recommendation_score
      SQL
    end
  end
end
