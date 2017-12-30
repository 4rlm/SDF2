class CreateActAdrs < ActiveRecord::Migration[5.1]
  def change
    create_table :act_adrs do |t|
      
      t.integer :act_id, index: true
      t.integer :adr_id, index: true

      t.timestamps
    end
  end
end
