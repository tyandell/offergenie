# frozen_string_literal: true

namespace :simulate do
  desc "Create 10 sample offers using ChatGPT"
  task create_offers: :environment do
    Simulate.create_offers!
  end
end
