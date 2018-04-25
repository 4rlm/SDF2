class CreatePhotos < ActiveRecord::Migration[5.1]
  def change
    create_table :photos do |t|

      t.attachment :image
      t.string :title
      t.string :content_type
      t.integer :user_id

      t.timestamps
    end
  end
end
