class Account < ApplicationRecord
  # has_many :contacts, inverse_of: :account, optional: true
  has_many :contacts
  accepts_nested_attributes_for :contacts

  has_many :account_addresses, dependent: :destroy
  has_many :addresses, through: :account_addresses
  accepts_nested_attributes_for :account_addresses, :addresses

  has_many :phonings, as: :phonable
  has_many :phones, through: :phonings
  accepts_nested_attributes_for :phonings, :phones

  has_many :webings, as: :webable
  has_many :webs, through: :webings
  accepts_nested_attributes_for :webings, :webs

  has_many :templatings, as: :templatable
  has_many :templates, through: :templatings
  accepts_nested_attributes_for :templatings, :templates

  has_many :brandings, as: :brandable
  has_many :brands, through: :brandings
  accepts_nested_attributes_for :brandings, :brands


  validates_uniqueness_of :crm_acct_num, allow_blank: true, allow_nil: true

end
