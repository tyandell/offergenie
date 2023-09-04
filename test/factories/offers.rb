# frozen_string_literal: true

FactoryBot.define do
  factory :offer do
    merchant
    title { Faker::Hipster.sentence[...100] }
    description { Faker::Hipster.paragraph[...5000] }

    trait :with_keywords do
      keywords { Faker::Hipster.words.join(" ")[...1000] }
    end

    trait :with_age_range do
      age_range { Demographic::AGE_RANGES.sample }
    end

    trait :with_gender do
      gender { Demographic::GENDERS.sample }
    end

    trait :limit_one do
      number_available { 1 }
    end
  end
end
