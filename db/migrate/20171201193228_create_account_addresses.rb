class CreateAccountAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :account_addresses do |t|
      t.integer :account_id, index: true
      t.integer :address_id, index: true

      # t.integer :account_id
      # t.integer :address_id

      t.timestamps
    end
  end
end
