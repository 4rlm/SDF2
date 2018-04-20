class CreateProcessStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :process_statuses do |t|

      t.integer :ver_url
      t.integer :find_temp
      t.integer :find_page
      t.integer :gp
      t.integer :find_brand
      t.integer :cont_scraper

      t.integer :url_total
      t.integer :temp_total
      t.integer :page_total
      t.integer :gp_total
      t.integer :brand_total
      t.integer :cont_total

      t.timestamps
    end
  end
end
