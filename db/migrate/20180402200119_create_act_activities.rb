class CreateActActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :act_activities do |t|
      t.references :user, index: true, null: false
      t.references :act, index: true, null: false
      t.integer :export_id
      # t.string :fav_sts
      # t.string :hide_sts
      t.boolean :fav_sts, index: true, null: false, default: FALSE
      t.boolean :hide_sts, index: true, null: false, default: FALSE

      t.timestamps
    end
    add_index :act_activities, [:user_id, :act_id], unique: true
  end
end
