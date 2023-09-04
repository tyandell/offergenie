# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails"

require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  fixtures :all
end
