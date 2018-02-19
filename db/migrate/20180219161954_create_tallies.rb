class CreateTallies < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'
    create_table :tallies do |t|

      t.integer :link_text_count, allow_nil: false
      t.citext  :staff_link, index: true, unique: true, allow_nil: false
      t.citext  :staff_text, index: true, unique: true, allow_nil: false
      t.string  :temp_name, allow_nil: false

    end
  end
end
