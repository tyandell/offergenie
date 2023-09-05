# frozen_string_literal: true

class AddApiColumnsToMerchants < ActiveRecord::Migration[7.0]
  def change
    change_table :merchants, bulk: true do |t|
      t.column :api_url, :string
      t.column :api_key, :string
    end
  end
end
