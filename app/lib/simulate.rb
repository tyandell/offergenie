# frozen_string_literal: true

module Simulate
  GENERATE_SYSTEM_PROMPT = <<~PROMPT
    The user will ask for some random sample data and provide an example.
    Always return only valid JSON that matches the example.
  PROMPT

  class << self
    def openai_client
      @openai_client ||= OpenAI::Client.new
    end

    def generate(prompt)
      parameters = {
        model: "gpt-3.5-turbo",
        messages: [
          { role: :system, content: GENERATE_SYSTEM_PROMPT },
          { role: :user, content: prompt }
        ]
      }
      response = openai_client.chat(parameters:)
      JSON.parse(response.dig("choices", 0, "message", "content"))
    end

    class << self
      def generator(name, prompt)
        define_method "generate_#{name}" do
          generate(prompt)
        end
      end
    end

    generator :offers, <<~PROMPT
      Generate 10 offers for discounts or special deals. Include a title,
      detailed description (up to five sentences), and a string of keywords
      (characters only, separated by spaces) that will be used to match offers
      to potential buyers.

      Example:
      [
        {
          "title": "25% Off Everything in Store",
          "description": "...",
          "keywords": "discount sale storewide clothing electronics homedecor"
        },
        {
          "title": "Free Shipping on Orders Over $50",
          "description": "...",
          "keywords": "freeshipping orders fashion accessories"
        },
        {
          "title": "Buy One Get One Free: Movie Tickets",
          "description": "...",
          "keywords": "bogo movietickets cinema showtimes"
        }
      ]
    PROMPT

    def create_offers!
      Offer.transaction do
        FactoryBot.create_list :merchant, 5

        merchants = Merchant.order("random()").first(10)

        generate_offers.each do |attributes|
          attributes[:merchant] = merchants.sample

          attributes[:number_available] = 10**rand(1..5) if rand > 0.5

          Offer.create! attributes
        end
      end
    end
  end
end
