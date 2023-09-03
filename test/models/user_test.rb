# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "factory" do
    assert FactoryBot.build(:user).valid?
  end

  test "duplicate username" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.build(:user, username: user1.username)
    assert_not user2.valid?
    assert user2.errors.of_kind?(:username, :taken)
  end

  test "age" do
    user = FactoryBot.build(:user, born_on: 35.years.ago)
    assert_equal 35, user.age.round
  end

  test "genders" do
    assert FactoryBot.build(:user, gender: "male").male?
    assert FactoryBot.build(:user, gender: "female").female?
    assert FactoryBot.build(:user, gender: "nonbinary").nonbinary?
    assert FactoryBot.build(:user, gender: "prefer_not_to_say_gender").prefer_not_to_say_gender?
  end
end
