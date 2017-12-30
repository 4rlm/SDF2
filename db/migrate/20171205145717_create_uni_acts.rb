class CreateUniActs < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_acts do |t|

    # Acts
      t.integer :act_id
      t.string :crm_act_num
      t.string :act_src
      t.string :act_sts
      t.string :act_name

    # Adrs
      t.integer :adr_id
      t.string :adr_sts
      t.string :street
      t.string :unit
      t.string :city
      t.string :state
      t.string :zip
      t.string :full_adr
      t.string :adr_pin
      t.float :latitude
      t.float :longitude

    # Phones
      t.string :phone

    # Dealer Templates
      t.string :template_name

    # Webs
      t.string :archived
      t.string :web_sts
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
