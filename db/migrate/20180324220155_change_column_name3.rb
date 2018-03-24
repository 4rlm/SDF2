class ChangeColumnName3 < ActiveRecord::Migration[5.1]
  def change
    rename_column :webs, :wq_name, :save_q
  end
end
