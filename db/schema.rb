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

ActiveRecord::Schema.define(version: 20171206170706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_addresses", force: :cascade do |t|
    t.integer "account_id"
    t.integer "address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_addresses_on_account_id"
    t.index ["address_id"], name: "index_account_addresses_on_address_id"
  end

  create_table "account_webs", force: :cascade do |t|
    t.integer "account_id"
    t.integer "web_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_webs_on_account_id"
    t.index ["web_id"], name: "index_account_webs_on_web_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "account_source"
    t.string "account_status"
    t.string "crm_acct_num"
    t.string "account_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_name"], name: "index_accounts_on_account_name"
    t.index ["account_source"], name: "index_accounts_on_account_source"
    t.index ["account_status"], name: "index_accounts_on_account_status"
    t.index ["crm_acct_num"], name: "index_accounts_on_crm_acct_num"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_source"
    t.string "address_status"
    t.string "street"
    t.string "unit"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "full_address"
    t.string "address_pin"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_pin"], name: "index_addresses_on_address_pin"
    t.index ["address_source"], name: "index_addresses_on_address_source"
    t.index ["address_status"], name: "index_addresses_on_address_status"
    t.index ["city"], name: "index_addresses_on_city"
    t.index ["full_address"], name: "index_addresses_on_full_address"
    t.index ["latitude"], name: "index_addresses_on_latitude"
    t.index ["longitude"], name: "index_addresses_on_longitude"
    t.index ["state"], name: "index_addresses_on_state"
    t.index ["street"], name: "index_addresses_on_street"
    t.index ["unit"], name: "index_addresses_on_unit"
    t.index ["zip"], name: "index_addresses_on_zip"
  end

  create_table "contact_descriptions", force: :cascade do |t|
    t.integer "contact_id"
    t.integer "description_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_contact_descriptions_on_contact_id"
    t.index ["description_id"], name: "index_contact_descriptions_on_description_id"
  end

  create_table "contact_titles", force: :cascade do |t|
    t.integer "contact_id"
    t.integer "title_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_contact_titles_on_contact_id"
    t.index ["title_id"], name: "index_contact_titles_on_title_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "contact_source"
    t.string "contact_status"
    t.integer "account_id"
    t.string "crm_acct_num"
    t.string "crm_cont_num"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_contacts_on_account_id"
    t.index ["contact_source"], name: "index_contacts_on_contact_source"
    t.index ["contact_status"], name: "index_contacts_on_contact_status"
    t.index ["crm_acct_num"], name: "index_contacts_on_crm_acct_num"
    t.index ["crm_cont_num"], name: "index_contacts_on_crm_cont_num"
    t.index ["email"], name: "index_contacts_on_email"
    t.index ["first_name"], name: "index_contacts_on_first_name"
    t.index ["last_name"], name: "index_contacts_on_last_name"
  end

  create_table "descriptions", force: :cascade do |t|
    t.string "job_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_description"], name: "index_descriptions_on_job_description"
  end

  create_table "phones", force: :cascade do |t|
    t.string "phone_source"
    t.string "phone_status"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_phones_on_phone"
    t.index ["phone_source"], name: "index_phones_on_phone_source"
    t.index ["phone_status"], name: "index_phones_on_phone_status"
  end

  create_table "phonings", force: :cascade do |t|
    t.string "phonable_type"
    t.integer "phone_id"
    t.integer "phonable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phonable_id"], name: "index_phonings_on_phonable_id"
    t.index ["phonable_type"], name: "index_phonings_on_phonable_type"
    t.index ["phone_id"], name: "index_phonings_on_phone_id"
  end

  create_table "titles", force: :cascade do |t|
    t.string "job_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_title"], name: "index_titles_on_job_title"
  end

  create_table "uni_accounts", force: :cascade do |t|
    t.integer "account_id"
    t.string "account_source"
    t.string "account_status"
    t.string "crm_acct_num"
    t.string "account_name"
    t.integer "address_id"
    t.string "address_source"
    t.string "address_status"
    t.string "street"
    t.string "unit"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "full_address"
    t.string "address_pin"
    t.float "latitude"
    t.float "longitude"
    t.integer "phone_id"
    t.string "phone_source"
    t.string "phone_status"
    t.string "phone"
    t.integer "web_id"
    t.string "web_source"
    t.string "web_status"
    t.string "url"
    t.string "staff_page"
    t.string "locations_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uni_contacts", force: :cascade do |t|
    t.string "contact_source"
    t.string "contact_status"
    t.integer "account_id"
    t.string "crm_acct_num"
    t.string "crm_cont_num"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "job_description"
    t.string "job_title"
    t.integer "phone_id"
    t.string "phone_source"
    t.string "phone_status"
    t.string "phone"
    t.integer "web_id"
    t.string "web_source"
    t.string "web_status"
    t.string "url"
    t.string "staff_page"
    t.string "locations_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "webings", force: :cascade do |t|
    t.string "webable_type"
    t.integer "web_id"
    t.integer "webable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["web_id"], name: "index_webings_on_web_id"
    t.index ["webable_id"], name: "index_webings_on_webable_id"
    t.index ["webable_type"], name: "index_webings_on_webable_type"
  end

  create_table "webs", force: :cascade do |t|
    t.string "web_source"
    t.string "web_status"
    t.string "url"
    t.string "staff_page"
    t.string "locations_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locations_page"], name: "index_webs_on_locations_page"
    t.index ["staff_page"], name: "index_webs_on_staff_page"
    t.index ["url"], name: "index_webs_on_url"
    t.index ["web_source"], name: "index_webs_on_web_source"
    t.index ["web_status"], name: "index_webs_on_web_status"
  end

end
