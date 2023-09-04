# frozen_string_literal: true

class UsersController < ApplicationController
  layout "auth"

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to root_path # TODO: Replace this with the offers page.
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
