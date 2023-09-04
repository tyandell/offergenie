# frozen_string_literal: true

FactoryBot.define do
  factory :activation do
    user
    offer
  end
end
