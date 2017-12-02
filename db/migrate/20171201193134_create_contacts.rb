class CreateContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :contacts do |t|
      t.string :source, index: true
      t.string :status, index: true
      t.integer :account_id, index: true
      t.string :crm_cont_num, index: true, unique: true
      t.string :first_name, index: true
      t.string :last_name, index: true
      t.string :email, index: true, unique: true

      t.timestamps
    end
  end
end
