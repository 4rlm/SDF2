class Address < ApplicationRecord
  has_many :act_addresses, dependent: :destroy
  has_many :acts, through: :act_addresses

  # attribute :full_address, :string
  # before_validation :full_address
  #
  # def full_address
  #   [street, city, state, zip].compact.join(',')
  # end


  # attribute :full_address, :string
  # before_validation :full_address

  # def full_address
  #   [street, unit, city, state, zip].compact.join(',')
  # end

  # validates_uniqueness_of :full_address, allow_blank: true, allow_nil: true


end
