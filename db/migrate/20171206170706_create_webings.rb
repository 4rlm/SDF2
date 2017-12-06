class CreateWebings < ActiveRecord::Migration[5.1]
  def change
    create_table :webings do |t|

      t.string :webable_type, index: true
      t.integer :web_id, index: true
      t.integer :webable_id, index: true

      t.timestamps
    end
  end
end
