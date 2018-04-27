class CreateS3s < ActiveRecord::Migration[5.1]
  def change
    create_table :s3s do |t|

      t.timestamps
    end
  end
end
