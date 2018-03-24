class CreateExports < ActiveRecord::Migration[5.1]
  def change
    create_table :exports do |t|
      t.references :user, index: true, null: false
      t.datetime :export_date, null: false
      t.string :file_name, null: false
    end
    # add_index :conts, [:web_id, :full_name], unique: true
    add_index :exports, [:user_id, :file_name], unique: true, name: 'user_exports'
  end
end
