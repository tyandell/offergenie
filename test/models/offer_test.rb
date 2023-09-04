# frozen_string_literal: true

require "test_helper"

class OfferTest < ActiveSupport::TestCase
  test "factory" do
    assert FactoryBot.build(:offer).valid?
    assert FactoryBot.build(:offer, :with_keywords).valid?
    assert FactoryBot.build(:offer, :with_age_range).valid?
    assert FactoryBot.build(:offer, :with_gender).valid?
    assert FactoryBot.build(:offer, :limit_one).valid?
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
end
