class CreateUniWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_webs do |t|

      t.boolean :archived
      t.string :web_status
      t.string :url
      t.string :url_redirect_id
      t.string :redirect_url

      t.string :staff_link
      t.string :staff_text
      t.string :staff_link_status

      t.string :locations_link
      t.string :locations_text
      t.string :locations_link_status

      t.timestamps
    end
  end
end