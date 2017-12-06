class CreateUniAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_accounts do |t|

    # Accounts
      t.integer "account_id"
      t.string "account_source"
      t.string "account_status"
      t.string "crm_acct_num"
      t.string "account_name"

    # Addresses
      t.integer "address_id"
      t.string "address_source"
      t.string "address_status"
      t.string "street"
      t.string "unit"
      t.string "city"
      t.string "state"
      t.string "zip"
      t.string "full_address"
      t.string "address_pin"
      t.float "latitude"
      t.float "longitude"

    # Phones
      t.integer "phone_id"
      t.string "phone_source"
      t.string "phone_status"
      t.string "phone"

    # Webs
      t.integer "web_id"
      t.string "web_source"
      t.string "web_status"
      t.string "url"
      t.string "staff_page"
      t.string "locations_page"

      t.timestamps
    end
  end
end
