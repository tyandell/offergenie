# frozen_string_literal: true

class UsersController < ApplicationController
  layout "card"

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      self.current_user = @user

      redirect_to offers_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(
        :username,
        :first_name,
        :last_name,
        :born_on,
        :gender,
        :password,
        :password_confirmation
      )
    end
end
