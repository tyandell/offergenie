# frozen_string_literal: true

class User < ApplicationRecord
  include ActiveModel::SecurePassword

  validates :username, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :born_on, presence: true

  GENDERS = [
    MALE = "male",
    FEMALE = "female",
    NONBINARY = "nonbinary",
    PREFER_NOT_TO_SAY_GENDER = "prefer_not_to_say_gender"
  ].freeze

  validates :gender, inclusion: GENDERS

  has_secure_password

  def age
    (Time.zone.today - born_on).days.in_years
  end

  GENDERS.each do |gender|
    define_method "#{gender}?" do
      self.gender == gender
    end
  end
end
