# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    name { Faker::Company.name }

    trait :with_api do
      api_url { Faker::Internet.url }
      api_key { Faker::Internet.uuid }
    end
  end
end
