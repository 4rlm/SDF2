class ChangeColumnName1 < ActiveRecord::Migration[5.1]
  def change
    rename_column :acts, :aq_name, :save_q
  end
end
