# frozen_string_literal: true

namespace :simulate do
  desc "Create 10 sample offers using ChatGPT"
  task create_offers: :environment do
    Simulate.create_offers!
  end

  desc "Rate keywords from 10 random offers using ChatGPT"
  task rate_keywords: :environment do
    Simulate.rate_keywords!
  end

  desc "Continuously rate keywords from 10 random offers using ChatGPT"
  task rate_keywords_loop: :environment do
    loop do
      Simulate.rate_keywords!

      sleep 10
    end
  end
end
