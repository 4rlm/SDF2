class CreateUniContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :uni_contacts do |t|

      t.timestamps
    end
  end
end
