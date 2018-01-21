class CreateUniWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_webs do |t|

      t.boolean :archived, default: false
      t.string :url_ver_sts
      t.string :url
      t.string :fwd_web_id
      t.string :fwd_url

      t.string :staff_link
      t.string :staff_text
      t.string :slink_sts

      t.string :locations_link
      t.string :locations_text
      t.string :locations_link_sts

      t.timestamps
    end
  end
end
