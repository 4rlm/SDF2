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

ActiveRecord::Schema.define(version: 20171201193259) do

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
    t.string "source"
    t.string "status"
    t.string "crm_acct_num"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_acct_num"], name: "index_accounts_on_crm_acct_num"
    t.index ["name"], name: "index_accounts_on_name"
    t.index ["source"], name: "index_accounts_on_source"
    t.index ["status"], name: "index_accounts_on_status"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "source"
    t.string "status"
    t.string "street"
    t.string "unit"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "address_pin"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_pin"], name: "index_addresses_on_address_pin"
    t.index ["city"], name: "index_addresses_on_city"
    t.index ["latitude"], name: "index_addresses_on_latitude"
    t.index ["longitude"], name: "index_addresses_on_longitude"
    t.index ["source"], name: "index_addresses_on_source"
    t.index ["state"], name: "index_addresses_on_state"
    t.index ["status"], name: "index_addresses_on_status"
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
    t.string "source"
    t.string "status"
    t.integer "account_id"
    t.string "crm_cont_num"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_contacts_on_account_id"
    t.index ["crm_cont_num"], name: "index_contacts_on_crm_cont_num"
    t.index ["email"], name: "index_contacts_on_email"
    t.index ["first_name"], name: "index_contacts_on_first_name"
    t.index ["last_name"], name: "index_contacts_on_last_name"
    t.index ["source"], name: "index_contacts_on_source"
    t.index ["status"], name: "index_contacts_on_status"
  end

  create_table "descriptions", force: :cascade do |t|
    t.string "job_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_description"], name: "index_descriptions_on_job_description"
  end

  create_table "phones", force: :cascade do |t|
    t.string "source"
    t.string "status"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_phones_on_phone"
    t.index ["source"], name: "index_phones_on_source"
    t.index ["status"], name: "index_phones_on_status"
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

  create_table "webs", force: :cascade do |t|
    t.string "source"
    t.string "status"
    t.string "url"
    t.string "staff_page"
    t.string "locations_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locations_page"], name: "index_webs_on_locations_page"
    t.index ["source"], name: "index_webs_on_source"
    t.index ["staff_page"], name: "index_webs_on_staff_page"
    t.index ["status"], name: "index_webs_on_status"
    t.index ["url"], name: "index_webs_on_url"
  end

end
