# frozen_string_literal: true

FactoryBot.define do
  factory :offer do
    merchant
    title { Faker::Hipster.sentence }
    description { Faker::Hipster.paragraph }

    trait :with_keywords do
      keywords { Faker::Hipster.words.join(" ") }
    end

    trait :with_age_range do
      age_range { Demographic::AGE_RANGES.sample }
    end

    trait :with_gender do
      gender { Demographic::GENDERS.sample }
    end
  end
end
