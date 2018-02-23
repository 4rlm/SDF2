class CreateActs < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'
    create_table :acts do |t|

      ## Account Name
      t.citext  :act_name, index: true, unique: true, allow_nil: true
      t.string  :gp_id, index: true, unique: true, allow_nil: true
      t.string  :gp_sts, index: true
      t.datetime :gp_date, index: true
      t.string  :gp_indus, index: true

      ## Address Info
      t.citext  :street, index: true
      t.citext  :city, index: true
      t.string  :state, index: true
      t.string  :zip, index: true
      t.citext  :full_address, index: true
      t.string  :phone, index: true

      # t.string  :url

      t.timestamps
    end
  end
end
