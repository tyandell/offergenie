# frozen_string_literal: true

FactoryBot.define do
  factory :activation do
    user
    offer

    coupon_code { Faker::Commerce.promotion_code }
  end
end
