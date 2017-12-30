class ActAdr < ApplicationRecord
  belongs_to :act
  belongs_to :adr

  accepts_nested_attributes_for :adr

  validates_uniqueness_of :act, scope: :adr_id

end
