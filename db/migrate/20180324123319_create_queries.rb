class CreateQueries < ActiveRecord::Migration[5.1]
  def change
    create_table :queries do |t|

      # t.references :user, index: true, null: false
      # t.string :search_name, index: true, null: false
      # t.string :mod_name, index: true, null: false

      t.integer :user_id
      t.string :search_name
      t.string :mod_name
      t.hstore :param_hsh

      t.timestamps
    end
    # add_index :queries, [:user_id, :search_name], unique: true, name: 'user_searches'
    add_index :queries, :param_hsh, using: :gin
  end
end

 # query = Query.create(mod_name: 'Web', param_hsh: {name: 'adam', city: 'austin'})
