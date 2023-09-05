# frozen_string_literal: true

module OfferActivation
  extend ActiveSupport::Concern

  ACTIVATION_METHODS = [
    ACTIVATION_CODE = :activation_code,
    COUPON_CODE = :coupon_code
  ].freeze

  class ActivationError < StandardError
  end

  included do
    include Lockable

    validates :number_available, numericality: { only_integer: true, greater_than: 0, allow_nil: true }

    validates :activation_code, presence: true, if: :uses_activation_code?
    validates :coupon_code, presence: true, if: :uses_coupon_code?

    has_many :activations, dependent: :destroy

    scope :available, -> { where(<<~SQL.squish) }
      number_available is null
      or
      (select count(activations.id) from activations where activations.offer_id = offers.id) < number_available
    SQL

    scope :unactivated_by, ->(user) {
      joins(sanitize_sql(["left outer join activations on activations.offer_id = offers.id and activations.user_id = ?", user.id]))
        .where(activations: { id: nil })
    }
  end

  def available?
    return true unless number_available

    activations.count < number_available
  end

  def activate!(user)
    with_advisory_lock do
      raise ActivationError, "Offer not available" unless available?

      coupon_code = merchant.perform_offer_activation(self)

      activations.create!(user:, coupon_code:)
    end
  end

  def activation_method
    return COUPON_CODE if coupon_code?

    ACTIVATION_CODE
  end

  ACTIVATION_METHODS.each do |activation_method|
    define_method "uses_#{activation_method}?" do
      self.activation_method == activation_method
    end
  end

  def activated_by?(user)
    activations.exists?(user:)
  end

  def unactivated_by?(user)
    !activated_by?(user)
  end
end
