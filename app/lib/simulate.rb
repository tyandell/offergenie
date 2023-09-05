# frozen_string_literal: true

module Simulate
  GENERATE_SYSTEM_PROMPT = <<~PROMPT
    The user will ask for some random sample data and provide an example.
    Always return only valid JSON that matches the example exactly, without
    wrapping it in another JSON object.
  PROMPT

  def self.openai_client
    @openai_client ||= OpenAI::Client.new
  end

  def self.generate(prompt)
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
    private
      def generator(name, prompt)
        define_singleton_method "generate_#{name}" do
          generate(prompt)
        end
      end
  end

  generator :offers, <<~PROMPT
    Generate 10 offers for discounts or special deals. Include a title,
    detailed description (up to five sentences), and a string of keywords
    (characters only, separated by spaces) that will be used to match offers to
    potential buyers.

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

  def self.create_offers!
    Offer.transaction do
      FactoryBot.create_list :merchant, 5

      merchants = Merchant.order("random()").first(10)

      generate_offers.each do |attributes|
        attributes[:merchant] = merchants.sample

        attributes[:number_available] = 10**rand(1..5) if rand > 0.5

        if rand > 0.5
          attributes[:activation_code] = Faker::Internet.uuid
        else
          attributes[:coupon_code] = Faker::Commerce.promotion_code
        end

        Offer.create! attributes
      end
    end
  end

  def self.rate_keywords!
    offers = Offer.order("random()").first(10)

    prompt = <<~PROMPT
      Given a list of demographics and offers for special deals or discounts,
      choose the best offer for each demographic, taking into account typical
      preferences for the age range and gender and the potential savings.

      The list of demographics is:
      #{Demographic.keys.sample(10).map(&:inspect).join("\n")}

      The list of offers is:
      #{offers.pluck(:title).map(&:inspect).join("\n")}

      Example:
      [
        ["18-24 male", "80% Off Electronics"],
        ["18-24 female", "Buy One Get One Half Off: Shoes"]
      ]
    PROMPT

    generate(prompt).each do |result|
      demographic = Demographic.from_key(result[0])
      next unless demographic

      offer = offers.find { |o| o.title == result[1] }
      next unless offer

      offer.keywords.split.each do |keyword|
        Rating.create! demographic_key: demographic.key, keyword:, value: 5
      end
    end
  end
end
