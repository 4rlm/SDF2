class CreateBrands < ActiveRecord::Migration[5.1]
  def change
    create_table :brands do |t|

      t.string :brand_term
      t.string :brand_name
      t.string :dealer_type

    end
  end
end
