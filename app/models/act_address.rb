class ActAddress < ApplicationRecord
  belongs_to :act
  belongs_to :address

  accepts_nested_attributes_for :address

  validates_uniqueness_of :act, scope: :address_id

end
