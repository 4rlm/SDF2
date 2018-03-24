class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.references :user, index: true, null: false
      t.references :export, index: true, null: false
      t.string :mod_name
      t.integer :mod_id
      t.string :fav_sts

      t.timestamps
    end
  end
end
