class Account < ApplicationRecord
  validates_uniqueness_of :crm_acct_num, allow_blank: true, allow_nil: true

  has_many :contacts, inverse_of: :account
  accepts_nested_attributes_for :contacts

  has_many :account_webs, dependent: :destroy
  has_many :webs, through: :account_webs
  accepts_nested_attributes_for :account_webs, :webs

  has_many :account_addresses, dependent: :destroy
  has_many :addresses, through: :account_addresses
  accepts_nested_attributes_for :account_addresses, :addresses




  has_many :phonings, as: :phonable
  has_many :phones, through: :phonings
  accepts_nested_attributes_for :phonings, :phones




end
