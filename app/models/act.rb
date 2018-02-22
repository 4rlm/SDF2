class Act < ApplicationRecord
  # has_many :conts, inverse_of: :act, optional: true
  validates_uniqueness_of :gp_id, allow_blank: true, allow_nil: true

  has_many :act_webs, dependent: :destroy
  has_many :webs, through: :act_webs
  has_many :conts, through: :webs

  accepts_nested_attributes_for :act_webs, :webs, :conts
end
