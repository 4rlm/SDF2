class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.string :contact_source, index: true
      t.string :contact_status, index: true
      t.integer :account_id, index: true
      # t.string :crm_acct_num, index: true
      t.string :crm_cont_num, index: true, unique: true, allow_nil: true
      t.string :first_name, index: true
      t.string :last_name, index: true
      t.string :email, index: true, unique: true, allow_nil: true

      # t.string :source
      # t.string :status
      # t.integer :account_id
      # t.string :crm_acct_num
      # t.string :crm_cont_num
      # t.string :first_name
      # t.string :last_name
      # t.string :email

      t.timestamps
    end
  end
end
