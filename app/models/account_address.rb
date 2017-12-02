class AccountAddress < ApplicationRecord
  belongs_to :account
  belongs_to :address

  accepts_nested_attributes_for :address

  validates_uniqueness_of :account, scope: :address_id

end
