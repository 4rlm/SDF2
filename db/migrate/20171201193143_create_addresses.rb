class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|

      t.string :address_status, index: true
      t.string :street, index: true
      t.string :unit, index: true
      t.string :city, index: true
      t.string :state, index: true
      t.string :zip, index: true
      t.string :full_address, index: true, unique: true, allow_nil: true
      t.string :address_pin, index: true
      t.float :latitude, index: true
      t.float :longitude, index: true

    end
  end
end
