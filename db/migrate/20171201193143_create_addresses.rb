class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :source, index: true
      t.string :status, index: true
      t.string :street, index: true
      t.string :unit, index: true
      t.string :city, index: true
      t.string :state, index: true
      t.string :zip, index: true
      t.string :address_pin, index: true
      t.float :latitude, index: true
      t.float :longitude, index: true

      t.timestamps
    end
  end
end
