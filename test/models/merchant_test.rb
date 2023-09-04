# frozen_string_literal: true

require "test_helper"

class MerchantTest < ActiveSupport::TestCase
  test "factory" do
    assert FactoryBot.build(:merchant).valid?
  end
end
