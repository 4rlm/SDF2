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

ActiveRecord::Schema.define(version: 20171219052552) do

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

  create_table "brandings", force: :cascade do |t|
    t.string "brandable_type"
    t.integer "brand_id"
    t.integer "brandable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_brandings_on_brand_id"
    t.index ["brandable_id"], name: "index_brandings_on_brandable_id"
    t.index ["brandable_type"], name: "index_brandings_on_brandable_type"
  end

  create_table "brands", force: :cascade do |t|
    t.string "brand_name"
    t.string "dealer_type"
    t.string "brand_term"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_term"], name: "index_brands_on_brand_term"
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
    t.string "crm_cont_num"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_contacts_on_account_id"
    t.index ["contact_source"], name: "index_contacts_on_contact_source"
    t.index ["contact_status"], name: "index_contacts_on_contact_status"
    t.index ["crm_cont_num"], name: "index_contacts_on_crm_cont_num"
    t.index ["email"], name: "index_contacts_on_email"
    t.index ["first_name"], name: "index_contacts_on_first_name"
    t.index ["last_name"], name: "index_contacts_on_last_name"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "descriptions", force: :cascade do |t|
    t.string "job_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_description"], name: "index_descriptions_on_job_description"
  end

  create_table "linkings", force: :cascade do |t|
    t.string "linkable_type"
    t.integer "link_id"
    t.integer "linkable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_linkings_on_link_id"
    t.index ["linkable_id"], name: "index_linkings_on_linkable_id"
    t.index ["linkable_type"], name: "index_linkings_on_linkable_type"
  end

  create_table "links", force: :cascade do |t|
    t.string "link"
    t.string "link_type"
    t.string "link_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link"], name: "index_links_on_link"
  end

  create_table "phones", force: :cascade do |t|
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_phones_on_phone"
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

  create_table "templates", force: :cascade do |t|
    t.string "template_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_name"], name: "index_templates_on_template_name"
  end

  create_table "templatings", force: :cascade do |t|
    t.string "templatable_type"
    t.integer "template_id"
    t.integer "templatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["templatable_id"], name: "index_templatings_on_templatable_id"
    t.index ["templatable_type"], name: "index_templatings_on_templatable_type"
    t.index ["template_id"], name: "index_templatings_on_template_id"
  end

  create_table "terms", force: :cascade do |t|
    t.string "category"
    t.string "sub_category"
    t.string "criteria_term"
    t.string "response_term"
    t.string "mth_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "textings", force: :cascade do |t|
    t.string "textable_type"
    t.integer "text_id"
    t.integer "textable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["text_id"], name: "index_textings_on_text_id"
    t.index ["textable_id"], name: "index_textings_on_textable_id"
    t.index ["textable_type"], name: "index_textings_on_textable_type"
  end

  create_table "texts", force: :cascade do |t|
    t.string "text"
    t.string "text_type"
    t.string "text_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["text"], name: "index_texts_on_text"
  end

  create_table "titles", force: :cascade do |t|
    t.string "job_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_title"], name: "index_titles_on_job_title"
  end

  create_table "uni_accounts", force: :cascade do |t|
    t.integer "account_id"
    t.string "crm_acct_num"
    t.string "account_source"
    t.string "account_status"
    t.string "account_name"
    t.integer "address_id"
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
    t.string "phone"
    t.string "template_name"
    t.string "archived"
    t.string "web_status"
    t.string "url"
    t.string "url_redirect_id"
    t.string "staff_page"
    t.string "locations_page"
    t.string "ip"
    t.string "server1"
    t.string "server2"
    t.string "registrant_name"
    t.string "registrant_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uni_contacts", force: :cascade do |t|
    t.integer "account_id"
    t.integer "contact_id"
    t.string "crm_acct_num"
    t.string "crm_cont_num"
    t.string "contact_source"
    t.string "contact_status"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "job_description"
    t.string "job_title"
    t.integer "phone_id"
    t.string "phone"
    t.integer "web_id"
    t.string "web_status"
    t.string "url"
    t.string "staff_page"
    t.string "locations_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uni_webs", force: :cascade do |t|
    t.boolean "archived"
    t.string "web_status"
    t.string "url"
    t.string "url_redirect_id"
    t.string "redirect_url"
    t.string "staff_link"
    t.string "staff_text"
    t.string "staff_link_status"
    t.string "locations_link"
    t.string "locations_text"
    t.string "locations_link_status"
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
    t.boolean "archived"
    t.string "web_status"
    t.string "url"
    t.string "url_redirect_id"
    t.string "staff_page"
    t.string "locations_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived"], name: "index_webs_on_archived"
    t.index ["locations_page"], name: "index_webs_on_locations_page"
    t.index ["staff_page"], name: "index_webs_on_staff_page"
    t.index ["url"], name: "index_webs_on_url"
    t.index ["url_redirect_id"], name: "index_webs_on_url_redirect_id"
    t.index ["web_status"], name: "index_webs_on_web_status"
  end

  create_table "whos", force: :cascade do |t|
    t.string "ip"
    t.string "server1"
    t.string "server2"
    t.string "registrant_name"
    t.string "registrant_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
