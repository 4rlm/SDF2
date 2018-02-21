class CreateActWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :act_webs do |t|

      t.integer :act_id, index: true, null: false
      t.integer :web_id, index: true, null: false

      t.timestamps
    end
    add_index :act_webs, [:act_id, :web_id], unique: true
  end
end
