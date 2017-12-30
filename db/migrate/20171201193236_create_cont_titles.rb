class CreateContTitles < ActiveRecord::Migration[5.1]
  def change
    create_table :cont_titles do |t|
      
      t.integer :cont_id, index: true
      t.integer :title_id, index: true

      t.timestamps
    end
  end
end
