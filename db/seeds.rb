# frozen_string_literal: true

if ENV.fetch("OPENAI_ACCESS_TOKEN", nil)
  Simulate.create_offers!
else
  FactoryBot.create_list :offer, 10
end
