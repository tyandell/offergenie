# frozen_string_literal: true

class CreateOffers < ActiveRecord::Migration[7.0]
  def change
    enable_extension :pg_trgm

    create_table :offers do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :title, null: false
      t.string :description, null: false
      t.string :keywords
      t.string :age_range
      t.string :gender

      t.integer :number_available

      t.timestamps

      t.index :keywords, using: :gist, opclass: :gist_trgm_ops
    end
  end
end
