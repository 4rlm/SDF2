class ContTitle < ApplicationRecord
  belongs_to :cont
  belongs_to :title

  accepts_nested_attributes_for :title

  validates_uniqueness_of :cont, scope: :title_id

end
