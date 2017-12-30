class CreateContDescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :cont_descriptions do |t|
      
      t.integer :cont_id, index: true
      t.integer :description_id, index: true

      t.timestamps
    end
  end
end
