# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    born_on { Faker::Date.between(from: 100.years.ago, to: 18.years.ago) }
    gender { User::GENDERS.sample }
    password { Faker::Internet.password }
  end
end
