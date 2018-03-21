class CreateExports < ActiveRecord::Migration[5.1]
  def change
    create_table :exports do |t|
      t.references :user, index: true, null: false
      t.datetime :export_date, null: false

      t.timestamps
    end
  end
end
