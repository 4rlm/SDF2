class CreateActs < ActiveRecord::Migration[5.1]
  def change
    create_table :acts do |t|

      t.string   :act_name, index: true, unique: true, allow_nil: true
      t.string   :crm_act_num, index: true, unique: true, allow_nil: true

      t.string   :act_sts, index: true
      t.string   :act_src, index: true
      t.boolean  :cop, default: false
      t.boolean  :act_archived, default: false
      t.string   :act_redirect_id, index: true

      t.string   :act_gp_sts, index: true
      t.datetime :act_gp_date, index: true
      t.string   :place_id, index: true
      t.string   :industry, index: true

      t.integer   :top_150
      t.integer   :ward_500

      t.timestamps
    end
  end
end
