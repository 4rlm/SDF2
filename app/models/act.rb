class Act < ApplicationRecord
  # has_many :conts, inverse_of: :act, optional: true
  has_many :conts
  accepts_nested_attributes_for :conts

  has_many :act_addresses, dependent: :destroy
  has_many :addresses, through: :act_addresses
  accepts_nested_attributes_for :act_addresses, :addresses

  has_many :phonings, as: :phonable
  has_many :phones, through: :phonings
  accepts_nested_attributes_for :phonings, :phones

  has_many :webings, as: :webable
  has_many :webs, through: :webings
  accepts_nested_attributes_for :webings, :webs

  # has_many :templatings, as: :templatable
  # has_many :templates, through: :templatings
  # accepts_nested_attributes_for :templatings, :templates

  has_many :brandings, as: :brandable
  has_many :brands, through: :brandings
  accepts_nested_attributes_for :brandings, :brands


  validates_uniqueness_of :crm_act_num, allow_blank: true, allow_nil: true
  # validates_uniqueness_of :crm_act_num

end
