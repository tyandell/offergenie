# frozen_string_literal: true

require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get root_url
    assert_response :success
  end
end
