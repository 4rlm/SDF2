class CreateExports < ActiveRecord::Migration[5.1]
  def change
    create_table :exports do |t|
      t.references :user, index: true, null: false
      t.datetime :export_date, null: false
    end
    # add_index :favorites, ['favoritor_id', 'favoritor_type'], name: 'fk_favorites'
    # add_index :conts, [:web_id, :full_name], unique: true
    add_index :exports, [:user_id, :export_date], unique: true, name: 'user_exports'
  end
end
