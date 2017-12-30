class ContDescription < ApplicationRecord
  belongs_to :cont
  belongs_to :description

  accepts_nested_attributes_for :description

  validates_uniqueness_of :cont, scope: :description_id

end
