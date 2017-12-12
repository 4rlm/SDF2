class CreateTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :templates do |t|
      
      t.string :template_name, index: true, unique: true

    end
  end
end
