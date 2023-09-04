# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_user_url
    assert_response :success
  end

  test "create with valid params" do
    assert_difference "User.count" do
      post users_url, params: { user: FactoryBot.attributes_for(:user) }
    end
    assert_response :redirect
  end

  test "create with invalid params" do
    assert_no_difference "User.count" do
      post users_url, params: { user: { username: "test" } }
    end
    assert_response :unprocessable_entity
  end
end
