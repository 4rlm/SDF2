class CreateRansackOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :ransack_options do |t|
      t.string :mod_name, index: true, null: false
      t.jsonb :option_hsh, null: false, default: '{}'
      t.timestamps
    end
    add_index  :ransack_options, :option_hsh, using: :gin
  end
end
