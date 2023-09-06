# frozen_string_literal: true

# Represents an activation of an offer by a user.
#
# See {Offer} and {OfferActivation} for details about offer activation.
class Activation < ApplicationRecord
  belongs_to :user
  belongs_to :offer

  validates :offer, uniqueness: { scope: :user }

  validates :coupon_code, presence: true

  # Returns scores used by {Recommender}.
  def self.scores
    # TODO: Implement this.
    {}
  end
end
