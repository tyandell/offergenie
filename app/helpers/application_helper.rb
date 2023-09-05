# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def debug?
    Rails.env.development? && params[:debug].present?
  end
end
