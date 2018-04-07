class CreateQueries < ActiveRecord::Migration[5.1]
  def change
    create_table :queries do |t|

      t.references :user, index: true, null: false
      t.string :q_name, index: true, null: false
      t.string :mod_name, index: true, null: false
      t.integer :row_count
      t.jsonb :params, null: false, default: '{}'

      t.timestamps
    end
    add_index  :queries, :params, using: :gin
    # add_index :queries, [:user_id, :q_name], unique: true, name: 'user_searches'
  end
end
