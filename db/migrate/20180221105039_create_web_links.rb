class CreateWebLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :web_links do |t|

      t.integer :web_id, index: true, null: false
      t.integer :link_id, index: true, null: false
      t.string  :link_sts, index: true
      t.integer :cs_count, default: 0

      t.timestamps
    end
    add_index :web_links, [:web_id, :link_id], unique: true
  end
end
