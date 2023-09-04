# frozen_string_literal: true

class Demographic
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

  class Error < StandardError
  end

  def self.parse_age_range(age_range)
    raise Error, "Unsupported age range: #{age_range.inspect}" unless AGE_RANGES.include?(age_range)

    if age_range.end_with?("+")
      min = age_range.delete_suffix("+").to_f
      return (min..Float::INFINITY)
    end

    min, max = age_range.scan(/\d+/)
    (min.to_f...(max.to_f + 1.0))
  end
end
