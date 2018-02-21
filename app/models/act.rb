class Act < ApplicationRecord
  # has_many :conts, inverse_of: :act, optional: true
  validates_uniqueness_of :gp_id, allow_blank: true, allow_nil: true

  has_many :conts
  accepts_nested_attributes_for :conts

  has_many :act_links, dependent: :destroy
  has_many :links, through: :act_links
  accepts_nested_attributes_for :act_links, :links

  has_many :act_webs, dependent: :destroy
  has_many :webs, through: :act_webs
  accepts_nested_attributes_for :act_webs, :webs

  has_many :brandings, as: :brandable
  has_many :brands, through: :brandings
  accepts_nested_attributes_for :brandings, :brands
end
