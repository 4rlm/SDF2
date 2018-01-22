class CreateConts < ActiveRecord::Migration[5.1]
  def change
    create_table :conts do |t|

      t.integer :act_id, index: true
      t.string :cont_sts, index: true
      t.string :first_name, index: true
      t.string :last_name, index: true
      t.string :email, index: true, unique: true, allow_nil: true
      t.string :job_title, index: true
      t.string :job_desc, index: true

      t.timestamps
    end
  end
end
