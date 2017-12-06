class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :account_source, index: true
      t.string :account_status, index: true
      t.string :crm_acct_num, index: true, unique: true, allow_nil: true
      t.string :account_name, index: true, unique: true

      # t.string :source
      # t.string :status
      # t.string :crm_acct_num
      # t.string :name

      t.timestamps
    end
  end
end
