class CreateUniActs < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_acts do |t|

    # Acts
      t.string   :act_name, index: true, unique: true, allow_nil: true
      t.string   :crm_act_num, index: true, unique: true, allow_nil: true

      t.string   :act_sts, index: true
      t.string   :act_src, index: true
      t.boolean  :cop, default: false
      t.boolean  :act_archived, default: false
      t.string   :act_redirect_id, index: true

      t.string   :act_gp_sts, index: true
      t.datetime :act_gp_date, index: true
      t.string   :place_id, index: true
      t.string   :industry, index: true

      t.integer   :top_150
      t.integer   :ward_500

    # Adrs
      t.string  :street, index: true
      t.string  :city, index: true
      t.string  :state, index: true
      t.string  :zip, index: true
      t.string  :adr_pin, index: true

      t.string  :adr_sts, index: true
      t.boolean :adr_archived, default: false

      t.string   :adr_gp_sts, index: true
      t.datetime :adr_gp_date, index: true

    # Phones
      t.string  :phone

    # Dealer Templates
      t.string  :template_name

    # Webs
      t.string   :url, index: true, unique: true
      t.boolean  :url_archived, default: false
      t.string   :web_sts, index: true
      t.string   :sts_code, index: true
      t.string   :url_redirect_id, index: true
      t.string   :redirect_url, index: true
      t.datetime :redirect_date, index: true

      t.string   :web_gp_sts, index: true
      t.datetime :web_gp_date, index: true

      t.string   :temp_sts, index: true
      t.datetime :temp_date, index: true

      t.string   :staff_link_sts, index: true
      t.string   :loc_link_sts, index: true
      t.string   :staff_text_sts, index: true
      t.string   :loc_text_sts, index: true
      t.datetime :link_text_date, index: true

      t.string   :acs_sts, index: true
      t.datetime :acs_date, index: true

      t.string   :cs_sts, index: true
      t.datetime :cs_date, index: true

    # Who
      t.string  :ip
      t.string  :server1
      t.string  :server2
      t.string  :registrant_name
      t.string  :registrant_email

      t.timestamps
    end
  end
end
