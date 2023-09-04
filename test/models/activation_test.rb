# frozen_string_literal: true

require "test_helper"

class ActivationTest < ActiveSupport::TestCase
  test "factory" do
    assert FactoryBot.build(:activation).valid?
  end

  test "only one activation per user" do
    activation1 = FactoryBot.create(:activation)
    activation2 = FactoryBot.build(:activation, user: activation1.user, offer: activation1.offer)
    assert_not activation2.valid?
    assert activation2.errors.of_kind?(:offer, :taken)
  end
end
