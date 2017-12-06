class CreateUniContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_contacts do |t|

    # CONTACTS
      t.string :contact_source
      t.string :contact_status
      t.integer :account_id
      t.string :crm_acct_num
      t.string :crm_cont_num
      t.string :first_name
      t.string :last_name
      t.string :email

    # JOB_DESCRIPTION
      t.string :job_description

    # JOB_TITLE
      t.string :job_title

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
