class CreateWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :webs do |t|

      t.boolean  :archived, index: true
      t.string   :web_sts, index: true
      t.string   :url, index: true, unique: true
      t.string   :url_redirect_id, index: true
      t.string   :redirect_url, index: true
      t.datetime :redirect_date, index: true

      t.string   :temp_sts, index: true
      t.datetime :temp_date, index: true

      t.string   :staff_link_sts, index: true
      t.string   :loc_link_sts, index: true
      t.string   :staff_text_sts, index: true
      t.string   :loc_text_sts, index: true
      t.datetime :link_text_date, index: true


      # t.string :staff_page, index: true, unique: true
      # t.string :locations_page, index: true, unique: true

      t.timestamps
    end
  end
end
