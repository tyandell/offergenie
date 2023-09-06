# frozen_string_literal: true

# Handles the offer recommendation algorithm.
#
# == The Algorithm
#
# There are three factors that combine to create a recommendation score for
# each offer. The offers are sorted by this score, with higher scores being
# shown to the user first.
#
# The primary factor used in recommendation is to compare how similar an
# offer's keywords are to the keywords that are recommended for the user's
# demographic. The best keywords for demographic are determined by
# {Recommender} which uses {Activation.scores} and {Rating.scores} as input.
# This is implemented in Postgres using a GiST index and +word_similarity+.
#
# Next, offer demographics are taken into account. If a merchant chose to
# specify a demographic (which would normally limit its reach), this gives it a
# boost for users in the same demographic.
#
# Finally, new offers are boosted. This allows for new kinds of offers with
# unrecognized keywords to be seen by users. They also get a "new" tag based on
# {Offer#new_boost?}.
#
# == Scopes
#
# +recommended_for+ --- Finds the offers recommended for a user
#
# @example Using +recommended_for+
#     Offer.recommended_for(User.first).first(5).pluck(:title)
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
