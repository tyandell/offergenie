# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "static_pages#index"

  resources :users, only: [:new, :create]
end
