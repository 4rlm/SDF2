class CreateTrackings < ActiveRecord::Migration[5.1]
  def change
    create_table :trackings do |t|
      t.references :track, index: true, foreign_key: true
      t.references :trackable, polymorphic: true, index: true

      t.timestamps
    end
    add_index :trackings, [:track_id, :trackable_type, :trackable_id], unique: true, name: 'trackings_index'
  end
end
