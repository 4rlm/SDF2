class CreateTitles < ActiveRecord::Migration[5.1]
  def change
    create_table :titles do |t|

      t.string :job_title, index: true, unique: true

      t.timestamps
    end
  end
end
