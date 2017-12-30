class CreateActs < ActiveRecord::Migration[5.1]
  def change
    create_table :acts do |t|

      t.string :act_src, index: true
      t.string :act_sts, index: true
      t.string :crm_act_num, index: true, unique: true, allow_nil: true
      t.string :act_name, index: true, unique: true, allow_nil: true

      t.timestamps
    end
  end
end
