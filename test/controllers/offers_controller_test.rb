# frozen_string_literal: true

require "test_helper"

class OffersControllerTest < ActionDispatch::IntegrationTest
  setup do
    FactoryBot.create_list :offer, 10
  end

  test "index without login" do
    get offers_url
    assert_response :redirect
  end

  test "index" do
    login
    get offers_url
    assert_response :success
  end
end
