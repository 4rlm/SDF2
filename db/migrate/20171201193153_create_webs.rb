class CreateWebs < ActiveRecord::Migration[5.1]
  def change
    create_table :webs do |t|

      ### url (url address) is Heart of Webs ##
      t.string   :url, index: true, unique: true
      t.boolean  :urlx, default: false
      ### UrlVerifier related Attrs  ##
      t.string   :fwd_web_id, index: true
      t.string   :fwd_url, index: true
      t.string   :url_ver_sts, index: true
      t.string   :sts_code, index: true
      t.datetime :url_ver_date, index: true
      ### TemplateFinder related Attrs ##
      t.string   :tmp_sts, index: true
      t.datetime :tmp_date, index: true
      ### PageFinder related Attrs ##
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

      t.timestamps
    end
  end
end
