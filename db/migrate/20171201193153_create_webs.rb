class CreateWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :webs do |t|
      t.string :source, index: true
      t.string :status, index: true
      t.string :url, index: true, unique: true
      t.string :staff_page, index: true, unique: true
      t.string :locations_page, index: true, unique: true

      t.timestamps
    end
  end
end
