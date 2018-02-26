class Act < ApplicationRecord
  # has_many :conts, inverse_of: :act, optional: true
  validates_uniqueness_of :gp_id, allow_blank: true, allow_nil: true

  has_one :act_web, dependent: :destroy
  has_one :web, through: :act_web
  has_many :conts, through: :web
  has_many :links, through: :web
  has_many :brands, through: :web

  accepts_nested_attributes_for :act_web, :web, :conts, :links, :brands
end
