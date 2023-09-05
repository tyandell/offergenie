# frozen_string_literal: true

require "test_helper"

class OfferTest < ActiveSupport::TestCase
  test "factory" do
    assert FactoryBot.build(:offer).valid?
    assert FactoryBot.build(:offer, :with_keywords).valid?
    assert FactoryBot.build(:offer, :with_age_range).valid?
    assert FactoryBot.build(:offer, :with_gender).valid?
    assert FactoryBot.build(:offer, :limit_one).valid?
    assert FactoryBot.build(:offer, :uses_activation_code).valid?
    assert FactoryBot.build(:offer, :uses_coupon_code).valid?
  end

  test "available scope" do
    FactoryBot.create_list :offer, 3

    offers = FactoryBot.create_list(:offer, 2, :limit_one)
    assert_equal 5, Offer.count
    assert_equal 5, Offer.available.count

    offers.each { |offer| FactoryBot.create(:activation, offer:) }
    assert_equal 5, Offer.count
    assert_equal 3, Offer.available.count
  end

  test "unactivated_by scope" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    offers = FactoryBot.create_list(:offer, 3)

    assert_equal 3, Offer.unactivated_by(user1).count
    assert_equal 3, Offer.unactivated_by(user2).count

    offers.each do |offer|
      FactoryBot.create(:activation, user: user1, offer:)
    end
    assert_equal 0, Offer.unactivated_by(user1).count
    assert_equal 3, Offer.unactivated_by(user2).count
  end

  test "available? without limit" do
    offer = FactoryBot.create(:offer)
    assert offer.available?
    FactoryBot.create(:activation, offer:)
    assert offer.available?
  end

  test "available? with limit one" do
    offer = FactoryBot.create(:offer, :limit_one)
    assert offer.available?
    FactoryBot.create(:activation, offer:)
    assert_not offer.available?
  end

  test "activated_by?" do
    activation = FactoryBot.create(:activation)
    assert activation.offer.activated_by?(activation.user)
  end

  test "unactivated_by?" do
    user = FactoryBot.create(:user)
    offer = FactoryBot.create(:offer)
    assert offer.unactivated_by?(user)
  end

  test "activate! limit" do
    offer = FactoryBot.create(:offer, :limit_one)

    user1 = FactoryBot.create(:user)
    assert_difference "offer.activations.count" do
      offer.activate! user1
    end

    user2 = FactoryBot.create(:user)
    assert_raises Offer::ActivationError do
      offer.activate! user2
    end
  end

  test "activate! returns activation" do
    user = FactoryBot.create(:user)

    offer = FactoryBot.create(:offer, :uses_activation_code)
    offer.merchant.stub :perform_offer_activation, Faker::Commerce.promotion_code do
      activation = offer.activate!(user)
      assert_kind_of Activation, activation
    end

    offer = FactoryBot.create(:offer, :uses_coupon_code)
    offer.merchant.stub :perform_offer_activation, Faker::Commerce.promotion_code do
      activation = offer.activate!(user)
      assert_kind_of Activation, activation
    end
  end

  test "activation_method" do
    offer = FactoryBot.build(:offer, :uses_activation_code)
    assert_equal Offer::ACTIVATION_CODE, offer.activation_method
    assert offer.uses_activation_code?

    offer = FactoryBot.build(:offer, :uses_coupon_code)
    assert_equal Offer::COUPON_CODE, offer.activation_method
    assert offer.uses_coupon_code?
  end
end
