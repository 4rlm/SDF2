class CreateAdrs < ActiveRecord::Migration[5.1]
  def change
    create_table :adrs do |t|

      t.string  :street, index: true
      t.string  :city, index: true
      t.string  :state, index: true
      t.string  :zip, index: true
      t.string  :adr_pin, index: true

      t.string  :adr_sts, index: true
      t.boolean :adr_archived, default: false

      t.string   :adr_gp_sts, index: true
      t.datetime :adr_gp_date, index: true

      t.timestamps
    end
  end
end
