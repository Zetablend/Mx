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

ActiveRecord::Schema[8.0].define(version: 2026_07_20_072400) do
  create_table "active_storage_attachments", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "full_name"
    t.string "phone"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "pincode"
    t.string "country"
    t.string "address_type"
    t.boolean "is_default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "banners", charset: "utf8mb3", force: :cascade do |t|
    t.string "title"
    t.string "link"
    t.string "device_type"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "brands", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cities", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.bigint "state_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "coupon_redemptions", charset: "utf8mb3", force: :cascade do |t|
    t.integer "user_id"
    t.integer "coupon_id"
    t.datetime "redeemed_at"
    t.string "location"
    t.string "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coupons", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.string "discount_type"
    t.decimal "value", precision: 10
    t.string "applicable_on"
    t.integer "max_usage_per_user"
    t.date "expiration_date"
    t.string "status"
    t.integer "user_id"
    t.integer "rule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faqs", charset: "utf8mb3", force: :cascade do |t|
    t.text "question"
    t.text "answer"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jwt_denylists", charset: "utf8mb3", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "login_activities", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "device"
    t.string "ip_address"
    t.string "location"
    t.datetime "login_time"
    t.boolean "is_current", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_login_activities_on_user_id"
  end

  create_table "merchant_coupons", charset: "utf8mb3", force: :cascade do |t|
    t.string "coupon_id"
    t.string "title"
    t.string "coupon_code"
    t.string "category"
    t.string "discount_type"
    t.decimal "discount_value", precision: 10
    t.date "valid_from"
    t.date "valid_till"
    t.string "status"
    t.integer "usage_limit"
    t.decimal "revenue", precision: 10
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notification_settings", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "email", default: true, null: false
    t.boolean "sms", default: false, null: false
    t.boolean "push", default: true, null: false
    t.boolean "marketing", default: false, null: false
    t.boolean "coupon", default: true, null: false
    t.boolean "offers", default: true, null: false
    t.boolean "subscription_expiry", default: true, null: false
    t.boolean "order_updates", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id", unique: true
  end

  create_table "notifications", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "message"
    t.string "notification_type"
    t.boolean "is_read"
    t.string "action_url"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_read"], name: "index_notifications_on_is_read"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "offers", charset: "utf8mb3", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "discount_type"
    t.decimal "value", precision: 10
    t.integer "category_id"
    t.date "start_date"
    t.date "end_date"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_options", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "provider"
    t.text "account_details"
    t.string "qr_image"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "privacy_settings", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "share_data_with_partners"
    t.boolean "personalized_ads"
    t.boolean "analytics_tracking"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_privacy_settings_on_user_id"
  end

  create_table "product_categories", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.decimal "price", precision: 10
    t.integer "stock"
    t.text "description"
    t.bigint "product_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
  end

  create_table "referral_plans", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "reward_type"
    t.decimal "reward_value", precision: 10
    t.date "expiration_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restaurants", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "address"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "qr_code"
    t.index ["category_id"], name: "index_restaurants_on_category_id"
  end

  create_table "reviews", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "restaurant_id", null: false
    t.integer "rating"
    t.text "comment"
    t.boolean "visible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_reviews_on_restaurant_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "roles", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "permissions"
  end

  create_table "rules", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "loyalty_program_type"
    t.string "trigger_event"
    t.string "stamp_type"
    t.integer "stamp_expiration"
    t.string "target_audience"
    t.string "event_types"
    t.json "voucher_rules"
    t.text "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subcategories", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_subcategories_on_category_id"
  end

  create_table "subscription_plans", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price", precision: 10
    t.integer "duration_days"
    t.boolean "status"
    t.json "features"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "support_tickets", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.string "subject"
    t.string "status", default: "Open"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_support_tickets_on_merchant_id"
  end

  create_table "ticket_messages", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.bigint "user_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_ticket_messages_on_ticket_id"
    t.index ["user_id"], name: "index_ticket_messages_on_user_id"
  end

  create_table "tickets", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "subject"
    t.text "message"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "user_referrals", charset: "utf8mb3", force: :cascade do |t|
    t.integer "user_id"
    t.integer "referred_user_id"
    t.string "referral_code"
    t.string "status"
    t.integer "referral_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.integer "role", default: 0
    t.string "name"
    t.string "otp"
    t.datetime "otp_sent_at"
    t.string "otp_token"
    t.datetime "otp_token_sent_at"
    t.string "referral_code"
    t.string "status"
    t.boolean "verified"
    t.boolean "blocked"
    t.integer "role_id"
    t.string "username"
    t.date "dob"
    t.string "gender"
    t.string "profile_image"
    t.string "language"
    t.string "currency"
    t.string "location"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["referral_code"], name: "index_users_on_referral_code", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "cities", "states"
  add_foreign_key "login_activities", "users"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "privacy_settings", "users"
  add_foreign_key "products", "product_categories"
  add_foreign_key "restaurants", "categories"
  add_foreign_key "reviews", "restaurants"
  add_foreign_key "reviews", "users"
  add_foreign_key "subcategories", "categories"
  add_foreign_key "support_tickets", "users", column: "merchant_id"
  add_foreign_key "ticket_messages", "tickets"
  add_foreign_key "ticket_messages", "users"
  add_foreign_key "tickets", "users"
end
