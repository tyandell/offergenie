# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails"

require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  fixtures :all

  def login(user = nil)
    user ||= FactoryBot.create(:user)
    post login_url, params: { username: user.username, password: user.password }
    user
  end

  def logout
    post logout_url
  end
end
