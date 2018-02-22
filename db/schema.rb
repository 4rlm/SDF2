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

ActiveRecord::Schema.define(version: 20180221105039) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"

  create_table "act_webs", force: :cascade do |t|
    t.integer "act_id", null: false
    t.integer "web_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_id", "web_id"], name: "index_act_webs_on_act_id_and_web_id", unique: true
    t.index ["act_id"], name: "index_act_webs_on_act_id"
    t.index ["web_id"], name: "index_act_webs_on_web_id"
  end

  create_table "acts", force: :cascade do |t|
    t.citext "act_name"
    t.string "gp_id"
    t.string "gp_sts"
    t.string "gp_indus"
    t.citext "street"
    t.citext "city"
    t.string "state"
    t.string "zip"
    t.citext "full_address"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_name"], name: "index_acts_on_act_name"
    t.index ["city"], name: "index_acts_on_city"
    t.index ["full_address"], name: "index_acts_on_full_address"
    t.index ["gp_id"], name: "index_acts_on_gp_id"
    t.index ["gp_indus"], name: "index_acts_on_gp_indus"
    t.index ["gp_sts"], name: "index_acts_on_gp_sts"
    t.index ["phone"], name: "index_acts_on_phone"
    t.index ["state"], name: "index_acts_on_state"
    t.index ["street"], name: "index_acts_on_street"
    t.index ["zip"], name: "index_acts_on_zip"
  end

  create_table "conts", force: :cascade do |t|
    t.integer "web_id"
    t.citext "first_name"
    t.citext "last_name"
    t.citext "full_name", null: false
    t.citext "job_title"
    t.citext "job_desc"
    t.citext "email"
    t.string "phone"
    t.string "cs_sts"
    t.datetime "cs_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cs_date"], name: "index_conts_on_cs_date"
    t.index ["cs_sts"], name: "index_conts_on_cs_sts"
    t.index ["email"], name: "index_conts_on_email"
    t.index ["first_name"], name: "index_conts_on_first_name"
    t.index ["full_name"], name: "index_conts_on_full_name"
    t.index ["job_desc"], name: "index_conts_on_job_desc"
    t.index ["job_title"], name: "index_conts_on_job_title"
    t.index ["last_name"], name: "index_conts_on_last_name"
    t.index ["phone"], name: "index_conts_on_phone"
    t.index ["web_id", "full_name"], name: "index_conts_on_web_id_and_full_name", unique: true
    t.index ["web_id"], name: "index_conts_on_web_id"
  end

  create_table "dashes", force: :cascade do |t|
    t.integer "count"
    t.string "category"
    t.citext "focus"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_dashes_on_category"
    t.index ["focus"], name: "index_dashes_on_focus"
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

  create_table "links", force: :cascade do |t|
    t.citext "staff_link", null: false
    t.citext "staff_text"
    t.index ["staff_link", "staff_text"], name: "index_links_on_staff_link_and_staff_text", unique: true
  end

  create_table "tallies", force: :cascade do |t|
    t.jsonb "acts", default: "{}", null: false
    t.jsonb "act_links", default: "{}", null: false
    t.jsonb "links", default: "{}", null: false
    t.jsonb "conts", default: "{}", null: false
    t.jsonb "webs", default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["act_links"], name: "index_tallies_on_act_links", using: :gin
    t.index ["acts"], name: "index_tallies_on_acts", using: :gin
    t.index ["conts"], name: "index_tallies_on_conts", using: :gin
    t.index ["links"], name: "index_tallies_on_links", using: :gin
    t.index ["webs"], name: "index_tallies_on_webs", using: :gin
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

  create_table "uni_acts", force: :cascade do |t|
    t.string "act_name"
    t.string "gp_id"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "url"
    t.string "sts_code"
    t.string "temp_name"
    t.string "staff_link"
    t.string "loc_link"
    t.boolean "actx"
    t.boolean "urlx"
    t.string "gp_sts"
    t.string "url_sts"
    t.string "temp_sts"
    t.string "page_sts"
    t.string "cs_sts"
    t.string "gp_indus"
    t.datetime "tmp_date"
    t.datetime "gp_date"
    t.datetime "page_date"
    t.datetime "url_date"
    t.datetime "cs_date"
    t.string "ip"
    t.string "server1"
    t.string "server2"
    t.string "registrant_name"
    t.string "registrant_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "web_links", force: :cascade do |t|
    t.integer "web_id", null: false
    t.integer "link_id", null: false
    t.string "link_sts"
    t.integer "cs_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_web_links_on_link_id"
    t.index ["link_sts"], name: "index_web_links_on_link_sts"
    t.index ["web_id", "link_id"], name: "index_web_links_on_web_id_and_link_id", unique: true
    t.index ["web_id"], name: "index_web_links_on_web_id"
  end

  create_table "webs", force: :cascade do |t|
    t.citext "url"
    t.string "url_sts_code"
    t.string "temp_name"
    t.datetime "tmp_date"
    t.datetime "gp_date"
    t.datetime "page_date"
    t.datetime "url_date"
    t.datetime "cs_date"
    t.string "url_sts"
    t.string "temp_sts"
    t.string "page_sts"
    t.string "cs_sts"
    t.integer "timeout", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cs_date"], name: "index_webs_on_cs_date"
    t.index ["cs_sts"], name: "index_webs_on_cs_sts"
    t.index ["gp_date"], name: "index_webs_on_gp_date"
    t.index ["page_date"], name: "index_webs_on_page_date"
    t.index ["page_sts"], name: "index_webs_on_page_sts"
    t.index ["temp_name"], name: "index_webs_on_temp_name"
    t.index ["temp_sts"], name: "index_webs_on_temp_sts"
    t.index ["tmp_date"], name: "index_webs_on_tmp_date"
    t.index ["url"], name: "index_webs_on_url"
    t.index ["url_date"], name: "index_webs_on_url_date"
    t.index ["url_sts"], name: "index_webs_on_url_sts"
    t.index ["url_sts_code"], name: "index_webs_on_url_sts_code"
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
