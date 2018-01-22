class CreateCrmas < ActiveRecord::Migration[5.1]
  def change
    create_table :crmas do |t|

      ## Will have to change this so crma is not unique.  Uniqueness of crma AND act_id, so it can act like a join table.
      t.string   :crma, index: true, unique: true, allow_nil: false

      t.timestamps
    end
  end
end
