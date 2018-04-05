class CreateContActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :cont_activities do |t|
      t.references :user, index: true, null: false
      t.references :cont, index: true, null: false
      t.integer :export_id
      # t.string :fav_sts
      # t.string :hide_sts
      t.boolean :fav_sts, index: true, null: false, default: FALSE
      t.boolean :hide_sts, index: true, null: false, default: FALSE

      t.timestamps
    end
    add_index :cont_activities, [:user_id, :cont_id], unique: true
  end
end
