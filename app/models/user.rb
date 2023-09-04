# frozen_string_literal: true

class User < ApplicationRecord
  include ActiveModel::SecurePassword

  validates :username, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :born_on, presence: true

  validates :gender, inclusion: Demographic::GENDERS

  has_secure_password

  has_many :activations, dependent: :destroy

  def age
    (Time.zone.today - born_on).days.in_years
  end

  Demographic::GENDERS.each do |gender|
    define_method "#{gender}?" do
      self.gender == gender
    end
  end

  def self.login(username, password)
    user = find_by(username:)
    return nil unless user
    return nil unless user.authenticate(password)

    user
  end
end
