class CreateConts < ActiveRecord::Migration[5.1]
  def change
    create_table :conts do |t|

      t.string :cont_src, index: true
      t.string :cont_sts, index: true
      t.integer :act_id, index: true
      # t.string :crm_act_num, index: true
      t.string :crm_cont_num, index: true, unique: true, allow_nil: true
      t.string :first_name, index: true
      t.string :last_name, index: true
      t.string :email, index: true, unique: true, allow_nil: true

      t.timestamps
    end
  end
end
