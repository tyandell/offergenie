# frozen_string_literal: true

class Merchant < ApplicationRecord
  validates :name, presence: true

  has_many :offers, dependent: :destroy

  class ActivationError < StandardError
  end

  def perform_offer_activation(offer)
    case offer.activation_method
    when Offer::ACTIVATION_CODE
      activate_offer_with_activation_code(offer.activation_code)
    when Offer::COUPON_CODE
      activate_offer_with_coupon_code(offer.coupon_code)
    else
      raise ActivationError, "Unsupported activation method: #{offer.activation_method.inspect}"
    end
  end

  private
    def api_client
      # I would use api_url and api_key here for real.
      @api_client ||= Faraday.new("https://httpbingo.org") do |f|
        f.request :json
        f.response :json
      end
    end

    def activate_offer_with_activation_code(activation_code)
      # This would be the path from api_url.
      api_client.post("/uuid", { activation_code: }).body["uuid"]
    end

    def activate_offer_with_coupon_code(coupon_code)
      coupon_code
    end
end
