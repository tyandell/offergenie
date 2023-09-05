# frozen_string_literal: true

require "test_helper"

class MerchantTest < ActiveSupport::TestCase
  test "factory" do
    assert FactoryBot.build(:merchant).valid?
    assert FactoryBot.build(:merchant, :with_api).valid?
  end

  test "activate offer using activation code" do
    offer = FactoryBot.create(:offer, :uses_activation_code)
    expected = Faker::Commerce.promotion_code
    # This would stub the API info from offer.merchant.
    stub_request(:post, "https://httpbingo.org/uuid")
      .with(
        body: { activation_code: offer.activation_code }.to_json
      )
      .to_return(
        status: 200,
        body: { uuid: expected }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    assert_equal expected, offer.merchant.perform_offer_activation(offer)
  end

  test "activate offer using coupon code" do
    offer = FactoryBot.create(:offer, :uses_coupon_code)
    assert_equal offer.coupon_code, offer.merchant.perform_offer_activation(offer)
  end
end
