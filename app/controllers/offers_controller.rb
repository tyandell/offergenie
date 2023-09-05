# frozen_string_literal: true

class OffersController < ApplicationController
  before_action :require_user

  def index
    @offers = Offer.available
                   .unactivated_by(current_user)
                   .recommended_for(current_user)
                   .order(id: :desc)
    @pagy, @offers = pagy(@offers, items: 12)
  end

  def activate
    offer = Offer.find(params[:id])

    activation = offer.activate!(current_user)

    redirect_to activation
  end
end
