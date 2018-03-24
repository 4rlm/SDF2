class ChangeColumnName2 < ActiveRecord::Migration[5.1]
  def change
    rename_column :conts, :cq_name, :save_q
  end
end
