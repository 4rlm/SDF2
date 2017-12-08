class CreateWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :webs do |t|
      t.string :web_status, index: true
      t.string :url, index: true, unique: true
      t.string :staff_page, index: true, unique: true
      t.string :locations_page, index: true, unique: true

      # t.string :source
      # t.string :status
      # t.string :url
      # t.string :staff_page
      # t.string :locations_page

    end
  end
end
