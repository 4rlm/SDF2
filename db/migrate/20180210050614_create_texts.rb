class CreateTexts < ActiveRecord::Migration[5.1]
  def change
    create_table :texts do |t|

      t.integer :count, allow_nil: false
      t.string  :temp_name, allow_nil: false
      t.string  :staff_text, index: true, unique: true, allow_nil: false
    end
  end
end
