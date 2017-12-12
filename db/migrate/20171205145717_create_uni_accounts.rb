class CreateUniAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_accounts do |t|

    # Accounts
      t.integer :account_id
      t.string :crm_acct_num
      t.string :account_source
      t.string :account_status
      t.string :account_name

    # Addresses
      t.integer :address_id
      t.string :address_status
      t.string :street
      t.string :unit
      t.string :city
      t.string :state
      t.string :zip
      t.string :full_address
      t.string :address_pin
      t.float :latitude
      t.float :longitude

    # Phones
      t.string :phone

    # Dealer Templates
      t.string :template_name

    # Webs
      t.string :archived
      t.string :web_status
      t.string :url
      t.string :url_redirect_id
      t.string :staff_page
      t.string :locations_page

    # Who
      t.string :ip
      t.string :server1
      t.string :server2
      t.string :registrant_name
      t.string :registrant_email

      t.timestamps
    end
  end
end
