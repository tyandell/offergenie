# frozen_string_literal: true

require "test_helper"

class ActivationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @activation = FactoryBot.create(:activation)
  end

  test "show" do
    login @activation.user
    get activation_url(@activation)
    assert_response :success
  end
end
