# frozen_string_literal: true

class Activation < ApplicationRecord
  belongs_to :user
  belongs_to :offer

  validates :offer, uniqueness: { scope: :user }

  def self.scores
    # TODO: Implement this.
    {}
  end
end
