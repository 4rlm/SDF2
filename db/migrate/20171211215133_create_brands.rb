class CreateBrands < ActiveRecord::Migration[5.1]
  def change
    create_table :brands do |t|

      t.string :brand_name
      t.string :dealer_type
      t.string :brand_term, index: true, unique: true

    end
  end
end
