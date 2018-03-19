class CreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.references :user, index: true, null: false
      t.string :track

      t.timestamps
    end
  end
end
