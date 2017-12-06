class CreatePhones < ActiveRecord::Migration[5.1]
  def change
    create_table :phones do |t|
      t.string :phone_source, index: true
      t.string :phone_status, index: true
      t.string :phone, index: true, unique: true

      # t.string :source
      # t.string :status
      # t.string :phone

      t.timestamps
    end
  end
end
