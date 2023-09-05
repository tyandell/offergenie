# frozen_string_literal: true

class ActivationsController < ApplicationController
  before_action :require_user

  def show
    @activation = current_user.activations.find(params[:id])
    @offer = @activation.offer
  end
end
