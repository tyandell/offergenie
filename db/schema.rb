# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_09_05_160544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "activations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "offer_id", null: false
    t.string "coupon_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["offer_id"], name: "index_activations_on_offer_id"
    t.index ["user_id", "offer_id"], name: "index_activations_on_user_id_and_offer_id", unique: true
    t.index ["user_id"], name: "index_activations_on_user_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_url"
    t.string "api_key"
  end

  create_table "offers", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.string "title", null: false
    t.string "description", null: false
    t.string "keywords"
    t.string "age_range"
    t.string "gender"
    t.integer "number_available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "activation_code"
    t.string "coupon_code"
    t.index ["keywords"], name: "index_offers_on_keywords", opclass: :gist_trgm_ops, using: :gist
    t.index ["merchant_id"], name: "index_offers_on_merchant_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.string "demographic_key", null: false
    t.string "keyword", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.date "born_on", null: false
    t.string "gender", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "activations", "offers"
  add_foreign_key "activations", "users"
  add_foreign_key "offers", "merchants"
end
