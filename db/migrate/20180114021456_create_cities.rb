class CreateCities < ActiveRecord::Migration[5.1]
  def change
    create_table :cities do |t|
      t.string :city_name
      t.string :state_code
      t.string :city_pop
  
      t.timestamps
    end
  end
end
