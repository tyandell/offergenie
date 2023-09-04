# frozen_string_literal: true

class Offer < ApplicationRecord
  belongs_to :merchant

  validates :title, presence: true, length: (3..100)
  validates :description, presence: true, length: (10..1000)
  validates :keywords, length: { maximum: 1000 }
  validates :age_range, inclusion: { in: Demographic::AGE_RANGES, allow_nil: true }
  validates :gender, inclusion: { in: Demographic::GENDERS, allow_nil: true }
end
