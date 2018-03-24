class CreateSearches < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :searches do |t|
      t.references :user, index: true, null: false
      t.string :search_name, index: true, null: false
      t.string :model_name, index: true, null: false
      t.jsonb :param_js, null: false, default: '{}'
      t.hstore :param_hsh

      t.timestamps
    end
    add_index :searches, [:user_id, :search_name], unique: true, name: 'user_searches'
    add_index :searches, :param_js, using: :gin
    add_index :searches, :param_hsh, using: :gin
  end
end
