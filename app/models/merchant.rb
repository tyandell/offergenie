# frozen_string_literal: true

class Merchant < ApplicationRecord
  validates :name, presence: true

  has_many :offers, dependent: :destroy
end
