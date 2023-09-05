# frozen_string_literal: true

module OfferRecommendation
  extend ActiveSupport::Concern

  NEW_BOOST_PERIOD = 15.minutes

  included do
    scope :recommended_for, ->(user) {
      select("*", recommendation_score_select_sql(user))
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

      sanitize_sql([<<~SQL.squish, keywords, NEW_BOOST_PERIOD.ago])
        (
          word_similarity(?, keywords) +
          case when created_at > ? then 100 else 0 end
        ) as recommendation_score
      SQL
    end
  end
end
