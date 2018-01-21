class CreateActs < ActiveRecord::Migration[5.1]
  def change
    create_table :acts do |t|

      ### act_name is Heart of Acts ##
      t.string   :act_name, index: true, unique: true, allow_nil: true
      t.boolean  :actx, default: false
      ### ActSource related Attrs ##
      t.string   :crma, index: true, unique: true, allow_nil: true
      t.boolean  :cop, default: false
      t.string   :top
      t.string   :ward
      ### GoogPlace related Attrs ##
      t.string   :act_fwd_id, index: true
      t.string   :act_gp_sts, index: true
      t.datetime :act_gp_date, index: true
      t.string   :act_gp_id, index: true
      t.string   :act_gp_indus, index: true

      t.timestamps
    end
  end
end
