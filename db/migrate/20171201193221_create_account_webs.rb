class CreateAccountWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :account_webs do |t|
      
      t.integer :account_id, index: true
      t.integer :web_id, index: true

      t.timestamps
    end
  end
end
