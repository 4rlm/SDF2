class CreateExportings < ActiveRecord::Migration[5.1]
  def change
    create_table :exportings do |t|
      t.references :export, index: true, foreign_key: true
      t.references :exportable, polymorphic: true, index: true

      t.timestamps
    end
    add_index :exportings, [:export_id, :exportable_type, :exportable_id], unique: true, name: 'exportings_index'
  end
end
