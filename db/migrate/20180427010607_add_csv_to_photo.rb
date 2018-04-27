class AddCsvToPhoto < ActiveRecord::Migration[5.1]
  def change
    add_attachment :photos, :csv
  end
end
