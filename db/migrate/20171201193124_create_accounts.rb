class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :source, index: true
      t.string :status, index: true
      t.string :crm_acct_num, index: true, unique: true, allow_nil: true
      t.string :name, index: true, unique: true

      t.timestamps
    end
  end
end
