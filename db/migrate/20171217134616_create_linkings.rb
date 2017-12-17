class CreateLinkings < ActiveRecord::Migration[5.1]
  def change
    create_table :linkings do |t|
      
      t.string :linkable_type, index: true
      t.integer :link_id, index: true
      t.integer :linkable_id, index: true

      t.timestamps
    end
  end
end
