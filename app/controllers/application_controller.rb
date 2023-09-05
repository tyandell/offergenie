# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionAuthentication
  include Pagy::Backend

  helper_method :current_user

  private
    def current_user
      @current_user ||= session_user
    end

    def current_user=(user)
      if user
        session_login user
      else
        session_logout
      end

      @current_user = user
    end

    def require_user
      return if current_user

      redirect_to login_path
    end
end
