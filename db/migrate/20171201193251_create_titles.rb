class CreateTitles < ActiveRecord::Migration[5.1]
  def change
    create_table :titles do |t|
      t.string :job_title, index: true, unique: true

      # t.string :job_title

    end
  end
end
