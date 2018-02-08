class CreateConts < ActiveRecord::Migration[5.1]
  def change
    create_table :conts do |t|

      t.integer :act_id, index: true
      t.string :first_name, index: true
      t.string :last_name, index: true
      t.string :full_name, index: true, allow_nil: false
      t.string :job_title, index: true
      t.string :job_desc, index: true
      t.string :email, index: true, unique: true, allow_nil: true
      t.string :phone, index: true

      t.timestamps
    end
    # add_index :conts, [:act_id, :full_name], unique: true, name: 'full_name_index' #=> And in Model!
    add_index :conts, [:act_id, :full_name], unique: true
  end
end
