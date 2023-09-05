# frozen_string_literal: true

class Demographic
  include ActiveModel::Model

  AGE_RANGES = [
    "18-24",
    "25-29",
    "30-34",
    "35-39",
    "40-49",
    "50-59",
    "60-69",
    "70-79",
    "80-89",
    "90+"
  ].freeze

  GENDERS = [
    MALE = "male",
    FEMALE = "female",
    NONBINARY = "nonbinary",
    PREFER_NOT_TO_SAY_GENDER = "prefer_not_to_say_gender"
  ].freeze

  attr_accessor :age_range
  attr_accessor :gender

  validates :age_range, inclusion: AGE_RANGES
  validates :gender, inclusion: GENDERS

  def self.keys
    AGE_RANGES.product(GENDERS).map do |age_range, gender|
      "#{age_range} #{gender}"
    end
  end

  def self.from_key(key)
    age_range, gender = key.split
    new(age_range:, gender:)
  end

  def self.from_key!(key)
    from_key(key).tap(&:validate!)
  end

  def key
    "#{age_range} #{gender}"
  end

  def include_age?(age)
    self.class.parse_age_range(age_range).include?(age)
  end

  class ParseError < StandardError
  end

  def self.parse_age_range(age_range)
    raise ParseError, "Unsupported age range: #{age_range.inspect}" unless AGE_RANGES.include?(age_range)

    if age_range.end_with?("+")
      min = age_range.delete_suffix("+").to_f
      return (min..Float::INFINITY)
    end

    min, max = age_range.scan(/\d+/)
    (min.to_f...(max.to_f + 1.0))
  end

  def self.age_range_for_age(age)
    AGE_RANGES.find do |age_range|
      parse_age_range(age_range).include?(age)
    end
  end
end
