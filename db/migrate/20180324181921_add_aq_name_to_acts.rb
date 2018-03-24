class AddAqNameToActs < ActiveRecord::Migration[5.1]
  def change
    add_column :acts, :aq_name, :string
  end
end
