# frozen_string_literal: true

class OffersController < ApplicationController
  before_action :require_user

  def index
    @offers = Offer.all
  end
end
