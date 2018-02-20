class CreateTallies < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'
    create_table :tallies do |t|

      t.integer :count, allow_nil: false
      t.string  :category, index: true, unique: true, allow_nil: false
      t.citext  :focus, index: true, unique: true, allow_nil: false

    end
    # add_index :tallies, [:staff_link, :staff_text], unique: true
  end
end