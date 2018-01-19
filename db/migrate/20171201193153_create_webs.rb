class CreateWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :webs do |t|

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

      t.timestamps
    end
  end
end
