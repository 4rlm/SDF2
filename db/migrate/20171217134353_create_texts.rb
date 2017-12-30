class CreateTexts < ActiveRecord::Migration[5.1]
  def change
    create_table :texts do |t|

      t.string :text, index: true, unique: true
      t.string :text_type
      t.string :text_sts

      t.timestamps
    end
  end
end
