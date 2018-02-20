class CreateActLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :act_links do |t|

      t.integer :act_id, index: true, null: false
      t.integer :link_id, index: true, null: false
      t.string  :link_sts, index: true
      t.integer :cs_count, default: 0

      t.timestamps
    end
    add_index :act_links, [:act_id, :link_id], unique: true
  end
end