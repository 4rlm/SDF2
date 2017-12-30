class CreateActWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :act_webs do |t|
      
      t.integer :act_id, index: true
      t.integer :web_id, index: true

      t.timestamps
    end
  end
end
