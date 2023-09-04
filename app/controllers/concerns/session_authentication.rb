# frozen_string_literal: true

module SessionAuthentication
  extend ActiveSupport::Concern

  def session_user
    sgid = session[:user]
    return nil unless sgid

    GlobalID::Locator.locate_signed(sgid, for: "session_user")
  end

  def session_login(user)
    session[:user] = user.to_sgid(for: "session_user")
  end

  def session_logout
    session.delete :user
  end
end
