class Adr < ApplicationRecord
  has_many :act_adrs, dependent: :destroy
  has_many :acts, through: :act_adrs

  # attribute :full_adr, :string
  # before_validation :full_adr
  #
  # def full_adr
  #   [street, city, state, zip].compact.join(',')
  # end


  # attribute :full_adr, :string
  # before_validation :full_adr

  # def full_adr
  #   [street, unit, city, state, zip].compact.join(',')
  # end

  # validates_uniqueness_of :full_adr, allow_blank: true, allow_nil: true


  UNRANSACKABLE_ATTRIBUTES = %w(id pin adrx adr_fwd_id adr_gp_sts adr_gp_date adr_gp_id adr_gp_indus created_at updated_at)
  def self.ransackable_attributes auth_object = nil
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end


end
