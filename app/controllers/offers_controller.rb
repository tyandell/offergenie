# frozen_string_literal: true

class OffersController < ApplicationController
  before_action :require_user

  def index
    @pagy, @offers = pagy(Offer.available.recommended_for(current_user), items: 12)
  end
end
