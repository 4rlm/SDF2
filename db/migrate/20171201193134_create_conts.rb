class CreateConts < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'
    create_table :conts do |t|

      t.integer :act_id, index: true
      t.integer :web_id, index: true
      t.citext :first_name, index: true
      t.citext :last_name, index: true
      t.citext :full_name, index: true, null: false
      t.citext :job_title, index: true
      t.citext :job_desc, index: true
      t.citext :email, index: true
      t.string :phone, index: true

      t.string  :cs_sts, index: true
      t.datetime :cs_date, index: true

      t.timestamps
    end
    # add_index :conts, [:act_id, :full_name], unique: true, name: 'full_name_index' #=> And in Model!
    # add_index :conts, [:act_id, :full_name], unique: true
    add_index :conts, [:web_id, :full_name], unique: true
    # add_index :conts, [:act_id, :email], unique: true
  end
end
