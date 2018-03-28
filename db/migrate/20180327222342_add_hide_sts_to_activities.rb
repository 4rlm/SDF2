class AddHideStsToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :hide_sts, :string
  end
end
