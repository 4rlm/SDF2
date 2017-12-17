class CreateTextings < ActiveRecord::Migration[5.1]
  def change
    create_table :textings do |t|
      
      t.string :textable_type, index: true
      t.integer :text_id, index: true
      t.integer :textable_id, index: true

      t.timestamps
    end
  end
end
