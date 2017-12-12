class CreateDescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :descriptions do |t|
      
      t.string :job_description, index: true, unique: true

    end
  end
end
