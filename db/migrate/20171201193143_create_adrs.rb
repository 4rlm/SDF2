class CreateAdrs < ActiveRecord::Migration[5.1]
  def change
    create_table :adrs do |t|

      ### address fields are Heart of Acts ##
      t.string  :street, index: true
      t.string  :city, index: true
      t.string  :state, index: true
      t.string  :zip, index: true
      t.string  :pin, index: true
      ### GoogPlace related Attrs ##
      t.boolean  :adrx, default: false
      t.string   :adr_fwd_id, index: true
      t.string   :adr_gp_sts, index: true
      t.datetime :adr_gp_date, index: true
      t.string   :adr_gp_id, index: true
      t.string   :adr_gp_indus, index: true

      t.timestamps
    end
  end
end
