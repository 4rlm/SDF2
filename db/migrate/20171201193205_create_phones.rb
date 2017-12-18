class CreatePhones < ActiveRecord::Migration[5.1]
  def change
    create_table :phones do |t|

      t.string :phone, index: true, unique: true

      t.timestamps
    end
  end
end
