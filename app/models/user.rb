# frozen_string_literal: true

# An OfferGenie end user.
#
# Along with authentication, this mainly provides a {demographic} that be used
# when matching offers to users.
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

  # Returns the matching {Demographic} for the user.
  #
  # @return [Demographic]
  def demographic
    Demographic.new(age_range: Demographic.age_range_for_age(age), gender:)
  end

  # Handles authentication.
  #
  # @param username [String]
  # @param password [String]
  #
  # @return [User, nil] If the login was correct, the user, otherwise +nil+
  def self.login(username, password)
    user = find_by(username:)
    return nil unless user
    return nil unless user.authenticate(password)

    user
  end
end
