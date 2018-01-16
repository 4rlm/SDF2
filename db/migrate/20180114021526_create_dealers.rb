class CreateDealers < ActiveRecord::Migration[5.1]
  def change
    create_table :dealers do |t|
      t.string :dealer_name
      t.string :dealer_length
      t.string :owner
      t.string :city
      t.string :state

      t.timestamps
    end
  end
end
