# frozen_string_literal: true

class AddCodeColumnsToOffers < ActiveRecord::Migration[7.0]
  def change
    change_table :offers, bulk: true do |t|
      t.column :activation_code, :string
      t.column :coupon_code, :string
    end
  end
end
