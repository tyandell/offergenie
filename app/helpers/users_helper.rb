# frozen_string_literal: true

module UsersHelper
  def gender_select_options
    Demographic::GENDERS.map do |gender|
      [t(gender, scope: :genders), gender]
    end
  end
end
