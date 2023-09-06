# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def debug?
    params[:debug].present?
  end
end
