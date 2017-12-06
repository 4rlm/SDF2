class CreatePhonings < ActiveRecord::Migration[5.1]
  def change
    create_table :phonings do |t|
      t.string :phonable_type, index: true
      t.integer :phone_id, index: true
      t.integer :phonable_id, index: true

      # t.string :phonable_type
      # t.integer :phone_id
      # t.integer :phonable_id

      t.timestamps
    end
  end
end
