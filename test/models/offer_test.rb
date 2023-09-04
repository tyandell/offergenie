# frozen_string_literal: true

require "test_helper"

class OfferTest < ActiveSupport::TestCase
  test "factory" do
    assert FactoryBot.build(:offer).valid?
    assert FactoryBot.build(:offer, :with_keywords).valid?
    assert FactoryBot.build(:offer, :with_age_range).valid?
    assert FactoryBot.build(:offer, :with_gender).valid?
  end
end
