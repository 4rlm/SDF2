class CreateUniActs < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_acts do |t|

      #### MIGRATES TO: ACT TABLE ####
      ### act_name is Heart of Acts ##
      t.string   :act_name, index: true, unique: true, allow_nil: true
      t.boolean  :actx, default: false
      ### ActSource related Attrs ##
      t.string   :crma, index: true, unique: true, allow_nil: true
      t.boolean  :cop, default: false
      t.string   :top
      t.string   :ward
      ### GpApi related Attrs ##
      t.string   :act_fwd_id, index: true
      t.string   :act_gp_sts, index: true
      t.datetime :act_gp_date, index: true
      t.string   :act_gp_id, index: true
      t.string   :act_gp_indus, index: true
      #####################################


      #### MIGRATES TO: ADR TABLE ####
      ### address fields are Heart of Acts ##
      t.string  :street, index: true
      t.string  :city, index: true
      t.string  :state, index: true
      t.string  :zip, index: true
      t.string  :pin, index: true
      ### GpApi related Attrs ##
      t.boolean  :adrx, default: false
      t.string   :adr_fwd_id, index: true
      t.string   :adr_gp_sts, index: true
      t.datetime :adr_gp_date, index: true
      t.string   :adr_gp_id, index: true
      t.string   :adr_gp_indus, index: true
      #####################################


      #### MIGRATES TO: WEBS TABLE ####
      ### url (website url) is Heart of Webs ##
      t.string   :url, index: true, unique: true
      t.boolean  :urlx, default: false
      ### VerUrl related Attrs  ##
      t.string   :fwd_web_id, index: true
      t.string   :fwd_url, index: true
      t.string   :url_ver_sts, index: true
      t.string   :sts_code, index: true
      t.datetime :url_ver_date, index: true
      ### FindTemp related Attrs ##
      t.string   :tmp_sts, index: true
      t.datetime :tmp_date, index: true
      ### FindPage related Attrs ##
      t.string   :slink_sts, index: true
      t.string   :llink_sts, index: true
      t.string   :stext_sts, index: true
      t.string   :ltext_sts, index: true
      t.datetime :pge_date, index: true
      ### ActScraper related Attrs ##
      t.string   :as_sts, index: true
      t.datetime :as_date, index: true
      ### ContScraper related Attrs ##
      t.string   :cs_sts, index: true
      t.datetime :cs_date, index: true
      #####################################


      #### MIGRATES TO: PHONE TABLE ####
      t.string  :phone
      #####################################


      #### MIGRATES TO: DEALER TABLE ####
      t.string  :temp_name
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
