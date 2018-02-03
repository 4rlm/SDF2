class Act < ApplicationRecord
  # has_many :conts, inverse_of: :act, optional: true
  has_many :conts
  accepts_nested_attributes_for :conts

  has_many :act_adrs, dependent: :destroy
  has_many :adrs, through: :act_adrs
  accepts_nested_attributes_for :act_adrs, :adrs

  has_many :phonings, as: :phonable
  has_many :phones, through: :phonings
  accepts_nested_attributes_for :phonings, :phones

  has_many :webings, as: :webable
  has_many :webs, through: :webings
  accepts_nested_attributes_for :webings, :webs

  has_many :brandings, as: :brandable
  has_many :brands, through: :brandings
  accepts_nested_attributes_for :brandings, :brands


  # UNRANSACKABLE_ATTRIBUTES = %w(actx cop top ward act_fwd_id act_gp_sts act_gp_id act_gp_indus created_at)
  # def self.ransackable_attributes auth_object = nil
  #   (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  # end

end
