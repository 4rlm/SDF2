class AddCqNameToConts < ActiveRecord::Migration[5.1]
  def change
    add_column :conts, :cq_name, :string
  end
end
