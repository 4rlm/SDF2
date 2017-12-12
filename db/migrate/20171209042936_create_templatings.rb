class CreateTemplatings < ActiveRecord::Migration[5.1]
  def change
    create_table :templatings do |t|

      t.string :templatable_type, index: true
      t.integer :template_id, index: true
      t.integer :templatable_id, index: true

      t.timestamps
    end
  end
end
