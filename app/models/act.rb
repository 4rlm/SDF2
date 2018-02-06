class Act < ApplicationRecord
  # has_many :conts, inverse_of: :act, optional: true
  validates_uniqueness_of :gp_id, allow_blank: true, allow_nil: true

  has_many :conts
  accepts_nested_attributes_for :conts

  has_many :brandings, as: :brandable
  has_many :brands, through: :brandings
  accepts_nested_attributes_for :brandings, :brands

end
