class CreateBrandings < ActiveRecord::Migration[5.1]
  def change
    create_table :brandings do |t|

      t.string :brandable_type, index: true
      t.integer :brand_id, index: true
      t.integer :brandable_id, index: true

      t.timestamps
    end
  end
end
