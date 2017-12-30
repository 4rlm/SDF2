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


end
