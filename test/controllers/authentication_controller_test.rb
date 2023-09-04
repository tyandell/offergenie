# frozen_string_literal: true

require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  test "login" do
    get login_url
    assert_response :success

    post login_url, params: { username: "", password: "" }
    assert_response :unprocessable_entity

    user = FactoryBot.create(:user)
    post login_url, params: { username: user.username, password: user.password }
    assert_response :redirect
  end

  test "logout" do
    post logout_url
    assert_response :redirect
  end
end
