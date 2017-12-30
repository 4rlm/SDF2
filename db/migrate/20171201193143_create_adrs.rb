class CreateAdrs < ActiveRecord::Migration[5.1]
  def change
    create_table :adrs do |t|

      t.string :adr_sts, index: true
      t.string :street, index: true
      # t.string :unit, index: true
      t.string :city, index: true
      t.string :state, index: true
      t.string :zip, index: true
      t.string :adr_pin, index: true
      # t.string :full_adr, index: true, unique: true, allow_nil: true
      # t.float :latitude, index: true
      # t.float :longitude, index: true

      t.timestamps
    end
  end
end
