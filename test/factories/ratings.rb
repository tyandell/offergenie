# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    demographic_key { Demographic.keys.sample }
    keyword { Faker::Hipster.word }
    value { [-10, -5, -1, 1, 5, 10].sample }
  end
end
