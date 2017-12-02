class Address < ApplicationRecord
  has_many :account_addresses, dependent: :destroy
  has_many :accounts, through: :account_addresses

  def full_address
    [street, city, state, zip].compact.join(',')
  end

end
