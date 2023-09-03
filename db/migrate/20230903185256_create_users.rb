# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username, null: false, index: { unique: true }
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :born_on, null: false
      t.string :gender, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
  end
end
