# frozen_string_literal: true

class CreateRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :ratings do |t|
      t.string :demographic_key, null: false
      t.string :keyword, null: false
      t.integer :value, null: false

      t.timestamps
    end
  end
end
