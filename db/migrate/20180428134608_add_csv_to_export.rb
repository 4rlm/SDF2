class AddCsvToExport < ActiveRecord::Migration[5.1]
  def change
    add_attachment :exports, :csv
  end
end
