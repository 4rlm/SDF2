class CreateLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :links do |t|

      t.integer :count, allow_nil: false
      t.string  :temp_name, allow_nil: false
      t.string  :staff_link, index: true, unique: true, allow_nil: false
    end
  end
end
