# frozen_string_literal: true

class CreateActivations < ActiveRecord::Migration[7.0]
  def change
    create_table :activations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :offer, null: false, foreign_key: true

      t.timestamps

      t.index [:user_id, :offer_id], unique: true
    end
  end
end
