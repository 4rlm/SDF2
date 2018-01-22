class CreateCrmcs < ActiveRecord::Migration[5.1]
  def change
    create_table :crmcs do |t|

      t.string   :crmc, index: true, unique: true, allow_nil: false
      t.integer  :crma_id, index: true, allow_nil: false

      t.timestamps
    end
  end
end
