# frozen_string_literal: true

class AuthenticationController < ApplicationController
  layout "card"

  def login
    return if request.get?

    user = User.login(params[:username], params[:password])
    if user
      self.current_user = user

      redirect_to root_path
    else
      @error = true
      render status: :unprocessable_entity
    end
  end

  def logout
    self.current_user = nil

    redirect_to root_path
  end
end
