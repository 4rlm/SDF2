class CreateActs < ActiveRecord::Migration[5.1]
  def change
    create_table :acts do |t|

      ## Account Name
      t.string  :act_name, index: true, unique: true, allow_nil: true
      t.string  :gp_id, index: true, unique: true, allow_nil: true

      ## Address Info
      t.string  :street, index: true
      t.string  :city, index: true
      t.string  :state, index: true
      t.string  :zip, index: true

      ## Extra Info
      t.string  :phone, index: true
      t.string  :url, index: true
      t.string  :url_sts_code, index: true
      t.string  :temp_name, index: true
      t.string  :staff_link, index: true
      t.string  :loc_link, index: true

      ## Deprecated
      t.boolean :actx, default: false
      t.boolean :urlx, default: false

      ## Statuses
      t.string  :gp_sts, index: true
      t.string  :url_sts, index: true
      t.string  :temp_sts, index: true
      t.string  :page_sts, index: true
      t.string  :cs_sts, index: true
      t.string  :gp_indus, index: true

      ## Dates
      t.datetime :tmp_date, index: true
      t.datetime :gp_date, index: true
      t.datetime :page_date, index: true
      t.datetime :url_date, index: true
      t.datetime :cs_date, index: true
      t.timestamps
    end
  end
end
