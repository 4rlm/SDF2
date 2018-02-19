class CreateActs < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'
    create_table :acts do |t|

      ## Account Name
      t.citext  :act_name, index: true, unique: true, allow_nil: true
      t.string  :gp_id, index: true, unique: true, allow_nil: true

      ## Address Info
      t.citext  :street, index: true
      t.citext  :city, index: true
      t.string  :state, index: true
      t.string  :zip, index: true
      t.citext  :full_address, index: true

      ## Extra Info
      t.string  :phone, index: true
      t.citext  :url, index: true
      t.string  :url_sts_code, index: true
      t.string  :temp_name, index: true
      t.citext  :staff_link, index: true
      t.citext  :staff_text, index: true

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
