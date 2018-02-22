class CreateWebs < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'
    create_table :webs do |t|

      t.citext  :url, index: true, unique: true, allow_nil: false
      t.string  :url_sts_code, index: true
      t.string  :temp_name, index: true

      ## Statuses
      t.string  :url_sts, index: true
      t.string  :temp_sts, index: true
      t.string  :page_sts, index: true
      t.string  :cs_sts, index: true
      t.integer :timeout, index: false, default: 0

      ## Dates
      t.datetime :url_date, index: true
      t.datetime :tmp_date, index: true
      t.datetime :page_date, index: true
      t.datetime :cs_date, index: true

      t.timestamps
    end
  end
end
