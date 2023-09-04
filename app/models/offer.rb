# frozen_string_literal: true

class Offer < ApplicationRecord
  include Lockable

  belongs_to :merchant

  validates :title, presence: true, length: (3..100)
  validates :description, presence: true, length: (10..1000)
  validates :keywords, length: { maximum: 1000 }
  validates :age_range, inclusion: { in: Demographic::AGE_RANGES, allow_nil: true }
  validates :gender, inclusion: { in: Demographic::GENDERS, allow_nil: true }

  validates :number_available, numericality: { only_integer: true, greater_than: 0, allow_nil: true }

  has_many :activations, dependent: :destroy

  scope :available, -> { where(<<~SQL.squish) }
    number_available is null
    or
    (select count(activations.id) from activations where activations.offer_id = offers.id) < number_available
  SQL

  def available?
    return true unless number_available

    activations.count < number_available
  end

  class ActivationError < StandardError
  end

  def activate!(user)
    with_advisory_lock do
      raise ActivationError, "Offer not available" unless available?

      activations.create!(user:)
    end
  end
end
