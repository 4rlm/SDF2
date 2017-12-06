class CreateContactDescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :contact_descriptions do |t|
      t.integer :contact_id, index: true
      t.integer :description_id, index: true

      # t.integer :contact_id
      # t.integer :description_id

      t.timestamps
    end
  end
end
