class CreateLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :links do |t|

      t.string :link, index: true, unique: true
      t.string :link_type
      t.string :link_status

      t.timestamps
    end
  end
end
