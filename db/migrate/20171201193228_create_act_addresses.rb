class CreateActAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :act_addresses do |t|
      
      t.integer :act_id, index: true
      t.integer :address_id, index: true

      t.timestamps
    end
  end
end
