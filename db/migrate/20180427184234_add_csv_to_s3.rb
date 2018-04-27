class AddCsvToS3 < ActiveRecord::Migration[5.1]
  def change
    add_attachment :s3s, :csv
  end
end
