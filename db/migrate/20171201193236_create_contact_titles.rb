class CreateContactTitles < ActiveRecord::Migration[5.1]
  def change
    create_table :contact_titles do |t|
      t.integer :contact_id, index: true
      t.integer :title_id, index: true

      # t.integer :contact_id
      # t.integer :title_id

      t.timestamps
    end
  end
end
