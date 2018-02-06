class CreateUniActs < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_acts do |t|

      #### MIGRATES TO: ACT TABLE ####
      ## Account Name
      t.string  :act_name
      t.string  :gp_id

      ## Address Info
      t.string  :street
      t.string  :city
      t.string  :state
      t.string  :zip

      ## Extra Info
      t.string  :phone
      t.string  :url
      t.string  :sts_code
      t.string  :temp_name
      t.string  :staff_link
      t.string  :loc_link

      ## Deprecated
      t.boolean :actx
      t.boolean :urlx

      ## Statuses
      t.string  :gp_sts
      t.string  :url_sts
      t.string  :temp_sts
      t.string  :page_sts
      t.string  :cs_sts
      t.string  :gp_indus

      ## Dates
      t.datetime :tmp_date
      t.datetime :gp_date
      t.datetime :page_date
      t.datetime :url_date
      t.datetime :cs_date
      #####################################

      #### MIGRATES TO: WHO TABLE ####
      t.string  :ip
      t.string  :server1
      t.string  :server2
      t.string  :registrant_name
      t.string  :registrant_email
      #####################################

      t.timestamps
    end
  end
end
