# frozen_string_literal: true

# The main offer model.
#
# Offers are listed by a {Merchant} and are recommended to a {User} based on
# their demographics. Users can then activate an offer to receive a coupon code
# that can be used with the merchant.
#
# Offer activation and availability is handled by {OfferActivation}.
#
# The offer recommendation algorithm is handled by {OfferRecommendation}.
class Offer < ApplicationRecord
  belongs_to :merchant

  validates :title, presence: true, length: (3..100)
  validates :description, presence: true, length: (10..5000)
  validates :keywords, length: { maximum: 1000 }
  validates :age_range, inclusion: { in: Demographic::AGE_RANGES, allow_nil: true }
  validates :gender, inclusion: { in: Demographic::GENDERS, allow_nil: true }

  include OfferActivation
  include OfferRecommendation

  # Should a "new" tag be shown on the offer?
  #
  # @return [Boolean]
  def new_boost?
    created_at >= NEW_BOOST_PERIOD.ago
  end
end
