# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_18_232400) do

  create_table "invoices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "week_id"
    t.float "earned", default: 0.0
    t.float "tips", default: 0.0
    t.float "adjustments", default: 0.0
    t.float "due", default: 0.0
    t.float "paid", default: 0.0
    t.boolean "wages_hourly", default: false
    t.boolean "wages_service_price_only", default: false
    t.float "wages_share", default: 0.0
    t.float "wages_fee_amount", default: 0.0
    t.integer "wages_fee_percent", default: 0
    t.integer "hours_earned", default: 0
    t.integer "hours_scheduled", default: 0
    t.boolean "invoice_sent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_invoices_on_team_id"
    t.index ["week_id"], name: "index_invoices_on_week_id"
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "color"
    t.string "tag_type"
    t.integer "launch_id"
    t.integer "ordering"
  end

  create_table "tags_teams", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "team_id"
    t.index ["tag_id"], name: "index_tags_teams_on_tag_id"
    t.index ["team_id"], name: "index_tags_teams_on_team_id"
  end

  create_table "teams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "first_name"
    t.string "last_name"
    t.integer "launch_id"
    t.boolean "status", default: true
    t.string "email"
    t.boolean "is_gst", default: false
    t.boolean "is_confirmed", default: false
    t.string "abn"
    t.string "billing_name"
    t.string "address"
    t.string "bsb"
    t.string "account_number"
    t.boolean "is_validated", default: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "is_admin", default: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "weeks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.date "payment_date"
    t.float "payment_total", default: 0.0
    t.boolean "is_busy", default: false
    t.datetime "busy_from"
    t.boolean "is_parsed", default: false
    t.datetime "parsed_at"
    t.boolean "is_processed", default: false
    t.datetime "processed_at"
    t.text "aba_file_gst"
    t.text "aba_file_no_gst"
    t.datetime "aba_created_at"
    t.boolean "is_past", default: false
  end

end
