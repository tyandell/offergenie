# frozen_string_literal: true

module OfferActivation
  extend ActiveSupport::Concern

  class ActivationError < StandardError
  end

  included do
    include Lockable

    validates :number_available, numericality: { only_integer: true, greater_than: 0, allow_nil: true }

    has_many :activations, dependent: :destroy

    scope :available, -> { where(<<~SQL.squish) }
      number_available is null
      or
      (select count(activations.id) from activations where activations.offer_id = offers.id) < number_available
    SQL
  end

  def available?
    return true unless number_available

    activations.count < number_available
  end

  def activate!(user)
    with_advisory_lock do
      raise ActivationError, "Offer not available" unless available?

      activations.create!(user:)
    end
  end
end
