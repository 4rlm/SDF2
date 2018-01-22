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

ActiveRecord::Schema.define(version: 20180121153846) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "act_adrs", force: :cascade do |t|
    t.integer "act_id"
    t.integer "adr_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_id"], name: "index_act_adrs_on_act_id"
    t.index ["adr_id"], name: "index_act_adrs_on_adr_id"
  end

  create_table "act_webs", force: :cascade do |t|
    t.integer "act_id"
    t.integer "web_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_id"], name: "index_act_webs_on_act_id"
    t.index ["web_id"], name: "index_act_webs_on_web_id"
  end

  create_table "acts", force: :cascade do |t|
    t.string "act_name"
    t.boolean "actx", default: false
    t.boolean "cop", default: false
    t.string "top"
    t.string "ward"
    t.string "act_fwd_id"
    t.string "act_gp_sts"
    t.datetime "act_gp_date"
    t.string "act_gp_id"
    t.string "act_gp_indus"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_fwd_id"], name: "index_acts_on_act_fwd_id"
    t.index ["act_gp_date"], name: "index_acts_on_act_gp_date"
    t.index ["act_gp_id"], name: "index_acts_on_act_gp_id"
    t.index ["act_gp_indus"], name: "index_acts_on_act_gp_indus"
    t.index ["act_gp_sts"], name: "index_acts_on_act_gp_sts"
    t.index ["act_name"], name: "index_acts_on_act_name"
  end

  create_table "adrs", force: :cascade do |t|
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "pin"
    t.boolean "adrx", default: false
    t.string "adr_fwd_id"
    t.string "adr_gp_sts"
    t.datetime "adr_gp_date"
    t.string "adr_gp_id"
    t.string "adr_gp_indus"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["adr_fwd_id"], name: "index_adrs_on_adr_fwd_id"
    t.index ["adr_gp_date"], name: "index_adrs_on_adr_gp_date"
    t.index ["adr_gp_id"], name: "index_adrs_on_adr_gp_id"
    t.index ["adr_gp_indus"], name: "index_adrs_on_adr_gp_indus"
    t.index ["adr_gp_sts"], name: "index_adrs_on_adr_gp_sts"
    t.index ["city"], name: "index_adrs_on_city"
    t.index ["pin"], name: "index_adrs_on_pin"
    t.index ["state"], name: "index_adrs_on_state"
    t.index ["street"], name: "index_adrs_on_street"
    t.index ["zip"], name: "index_adrs_on_zip"
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

  create_table "cities", force: :cascade do |t|
    t.string "city_name"
    t.string "state_code"
    t.string "city_pop"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conts", force: :cascade do |t|
    t.integer "act_id"
    t.string "cont_sts"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "job_title"
    t.string "job_desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_id"], name: "index_conts_on_act_id"
    t.index ["cont_sts"], name: "index_conts_on_cont_sts"
    t.index ["email"], name: "index_conts_on_email"
    t.index ["first_name"], name: "index_conts_on_first_name"
    t.index ["job_desc"], name: "index_conts_on_job_desc"
    t.index ["job_title"], name: "index_conts_on_job_title"
    t.index ["last_name"], name: "index_conts_on_last_name"
  end

  create_table "crmas", force: :cascade do |t|
    t.string "crma"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crma"], name: "index_crmas_on_crma"
  end

  create_table "crmcs", force: :cascade do |t|
    t.string "crmc"
    t.integer "crma_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crma_id"], name: "index_crmcs_on_crma_id"
    t.index ["crmc"], name: "index_crmcs_on_crmc"
  end

  create_table "dealers", force: :cascade do |t|
    t.string "dealer_name"
    t.string "dealer_length"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "link_sts"
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
    t.string "text_sts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["text"], name: "index_texts_on_text"
  end

  create_table "uni_acts", force: :cascade do |t|
    t.string "act_name"
    t.boolean "actx", default: false
    t.string "crma"
    t.boolean "cop", default: false
    t.string "top"
    t.string "ward"
    t.string "act_fwd_id"
    t.string "act_gp_sts"
    t.datetime "act_gp_date"
    t.string "act_gp_id"
    t.string "act_gp_indus"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "pin"
    t.boolean "adrx", default: false
    t.string "adr_fwd_id"
    t.string "adr_gp_sts"
    t.datetime "adr_gp_date"
    t.string "adr_gp_id"
    t.string "adr_gp_indus"
    t.string "url"
    t.boolean "urlx", default: false
    t.string "fwd_web_id"
    t.string "fwd_url"
    t.string "url_ver_sts"
    t.string "sts_code"
    t.datetime "url_ver_date"
    t.string "tmp_sts"
    t.datetime "tmp_date"
    t.string "slink_sts"
    t.string "llink_sts"
    t.string "stext_sts"
    t.string "ltext_sts"
    t.datetime "pge_date"
    t.string "as_sts"
    t.datetime "as_date"
    t.string "cs_sts"
    t.datetime "cs_date"
    t.string "phone"
    t.string "temp_name"
    t.string "ip"
    t.string "server1"
    t.string "server2"
    t.string "registrant_name"
    t.string "registrant_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_fwd_id"], name: "index_uni_acts_on_act_fwd_id"
    t.index ["act_gp_date"], name: "index_uni_acts_on_act_gp_date"
    t.index ["act_gp_id"], name: "index_uni_acts_on_act_gp_id"
    t.index ["act_gp_indus"], name: "index_uni_acts_on_act_gp_indus"
    t.index ["act_gp_sts"], name: "index_uni_acts_on_act_gp_sts"
    t.index ["act_name"], name: "index_uni_acts_on_act_name"
    t.index ["adr_fwd_id"], name: "index_uni_acts_on_adr_fwd_id"
    t.index ["adr_gp_date"], name: "index_uni_acts_on_adr_gp_date"
    t.index ["adr_gp_id"], name: "index_uni_acts_on_adr_gp_id"
    t.index ["adr_gp_indus"], name: "index_uni_acts_on_adr_gp_indus"
    t.index ["adr_gp_sts"], name: "index_uni_acts_on_adr_gp_sts"
    t.index ["as_date"], name: "index_uni_acts_on_as_date"
    t.index ["as_sts"], name: "index_uni_acts_on_as_sts"
    t.index ["city"], name: "index_uni_acts_on_city"
    t.index ["crma"], name: "index_uni_acts_on_crma"
    t.index ["cs_date"], name: "index_uni_acts_on_cs_date"
    t.index ["cs_sts"], name: "index_uni_acts_on_cs_sts"
    t.index ["fwd_url"], name: "index_uni_acts_on_fwd_url"
    t.index ["fwd_web_id"], name: "index_uni_acts_on_fwd_web_id"
    t.index ["llink_sts"], name: "index_uni_acts_on_llink_sts"
    t.index ["ltext_sts"], name: "index_uni_acts_on_ltext_sts"
    t.index ["pge_date"], name: "index_uni_acts_on_pge_date"
    t.index ["pin"], name: "index_uni_acts_on_pin"
    t.index ["slink_sts"], name: "index_uni_acts_on_slink_sts"
    t.index ["state"], name: "index_uni_acts_on_state"
    t.index ["stext_sts"], name: "index_uni_acts_on_stext_sts"
    t.index ["street"], name: "index_uni_acts_on_street"
    t.index ["sts_code"], name: "index_uni_acts_on_sts_code"
    t.index ["tmp_date"], name: "index_uni_acts_on_tmp_date"
    t.index ["tmp_sts"], name: "index_uni_acts_on_tmp_sts"
    t.index ["url"], name: "index_uni_acts_on_url"
    t.index ["url_ver_date"], name: "index_uni_acts_on_url_ver_date"
    t.index ["url_ver_sts"], name: "index_uni_acts_on_url_ver_sts"
    t.index ["zip"], name: "index_uni_acts_on_zip"
  end

  create_table "uni_conts", force: :cascade do |t|
    t.integer "act_id"
    t.integer "cont_id"
    t.string "crma"
    t.string "crmc"
    t.string "cont_sts"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "job_desc"
    t.string "job_title"
    t.integer "phone_id"
    t.string "phone"
    t.integer "web_id"
    t.string "url_ver_sts"
    t.string "url"
    t.string "staff_page"
    t.string "locations_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uni_webs", force: :cascade do |t|
    t.boolean "archived", default: false
    t.string "url_ver_sts"
    t.string "url"
    t.string "fwd_web_id"
    t.string "fwd_url"
    t.string "staff_link"
    t.string "staff_text"
    t.string "slink_sts"
    t.string "locations_link"
    t.string "locations_text"
    t.string "locations_link_sts"
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
    t.string "url"
    t.boolean "urlx", default: false
    t.string "fwd_web_id"
    t.string "fwd_url"
    t.string "url_ver_sts"
    t.string "sts_code"
    t.datetime "url_ver_date"
    t.string "tmp_sts"
    t.string "temp_name"
    t.datetime "tmp_date"
    t.string "slink_sts"
    t.string "llink_sts"
    t.string "stext_sts"
    t.string "ltext_sts"
    t.datetime "pge_date"
    t.string "as_sts"
    t.datetime "as_date"
    t.string "cs_sts"
    t.datetime "cs_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["as_date"], name: "index_webs_on_as_date"
    t.index ["as_sts"], name: "index_webs_on_as_sts"
    t.index ["cs_date"], name: "index_webs_on_cs_date"
    t.index ["cs_sts"], name: "index_webs_on_cs_sts"
    t.index ["fwd_url"], name: "index_webs_on_fwd_url"
    t.index ["fwd_web_id"], name: "index_webs_on_fwd_web_id"
    t.index ["llink_sts"], name: "index_webs_on_llink_sts"
    t.index ["ltext_sts"], name: "index_webs_on_ltext_sts"
    t.index ["pge_date"], name: "index_webs_on_pge_date"
    t.index ["slink_sts"], name: "index_webs_on_slink_sts"
    t.index ["stext_sts"], name: "index_webs_on_stext_sts"
    t.index ["sts_code"], name: "index_webs_on_sts_code"
    t.index ["temp_name"], name: "index_webs_on_temp_name"
    t.index ["tmp_date"], name: "index_webs_on_tmp_date"
    t.index ["tmp_sts"], name: "index_webs_on_tmp_sts"
    t.index ["url"], name: "index_webs_on_url"
    t.index ["url_ver_date"], name: "index_webs_on_url_ver_date"
    t.index ["url_ver_sts"], name: "index_webs_on_url_ver_sts"
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
