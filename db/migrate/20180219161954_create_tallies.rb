class CreateTallies < ActiveRecord::Migration[5.1]
  def change
    create_table :tallies do |t|

      t.jsonb :acts, null: false, default: '{}'
      t.jsonb :act_links, null: false, default: '{}'
      t.jsonb :links, null: false, default: '{}'
      t.jsonb :conts, null: false, default: '{}'

      t.timestamps
    end

    add_index  :tallies, :acts, using: :gin
    add_index  :tallies, :act_links, using: :gin
    add_index  :tallies, :links, using: :gin
    add_index  :tallies, :conts, using: :gin
  end
end
