class CreatePhones < ActiveRecord::Migration[5.1]
  def change
    create_table :phones do |t|
      t.string :phone, index: true, unique: true

      # t.string :source
      # t.string :status
      # t.string :phone

    end
  end
end
