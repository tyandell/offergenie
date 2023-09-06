# frozen_string_literal: true

# Handles offer activation and availability.
#
# Offers must be activated by a {User}. When activated, an {Activation} record
# is created which stores the user's unique coupon code for the offer and
# prevents the user from activating the offer again.
#
# == Activation Methods
#
# There are two different ways of activating offers.
#
# If an offer uses +:activation_code+, the activation code will be submitted to
# the merchant and new coupon code will be returned that should be unique to
# that customer. The new coupon code is stored in an {Activation}.
#
# If an offer uses +:coupon_code+, then it just stores a static coupon code
# that will be given to the user. It's still passed through
# {Merchant.perform_offer_activation} before being stored in the {Activation}.
#
# == Availability
#
# Offers may not always be available. Offers can have a +number_available+
# value, and once that many activations have happened, the offer disappears.
# The availability is checked by {activate!} and this is done within a
# transaction using Postgres advisory locks (see {Lockable}).
#
# == Scopes
#
# +available+ --- Limits the offers to ones that are still available
#
# +unactivated_by+ --- Finds offers that haven't been activated by a user
#
# @example Using +available+
#     Offer.available.count
#     # SELECT COUNT(*) FROM "offers" WHERE (number_available is null or (select count(activations.id) from activations where activations.offer_id = offers.id) < number_available)
#
# @example Using +unactivated_by+
#     Offer.unactivated_by(User.first).count
#     # SELECT "offers".* FROM "offers" left outer join activations on activations.offer_id = offers.id and activations.user_id = 1 WHERE "activations"."id" IS NULL
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

  # Is the offer still available?
  #
  # @return [Boolean]
  def available?
    return true unless number_available

    activations.count < number_available
  end

  # Performs activation on the offer with the merchant.
  #
  # @return [Activation] The resulting activation
  def activate!(user)
    with_advisory_lock do
      raise ActivationError, "Offer not available" unless available?

      coupon_code = merchant.perform_offer_activation(self)

      activations.create!(user:, coupon_code:)
    end
  end

  # Returns the offer's activation method.
  #
  # This will be one of {ACTIVATION_METHODS}.
  #
  # You can also use +uses_activation_code?+ or +uses_coupon_code?+ to check
  # the offer's activation method.
  #
  # @return [Symbol]
  def activation_method
    return COUPON_CODE if coupon_code?

    ACTIVATION_CODE
  end

  ACTIVATION_METHODS.each do |activation_method|
    define_method "uses_#{activation_method}?" do
      self.activation_method == activation_method
    end
  end

  # Has the offer been activated by +user+?
  #
  # @param user [User]
  #
  # @return [Boolean]
  def activated_by?(user)
    activations.exists?(user:)
  end

  # Has the offer _not_ been activated by +user+?
  #
  # @param user [User]
  #
  # @return [Boolean]
  def unactivated_by?(user)
    !activated_by?(user)
  end
end
