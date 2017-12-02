class AccountWeb < ApplicationRecord
  belongs_to :account
  belongs_to :web

  accepts_nested_attributes_for :web

  validates_uniqueness_of :account, scope: :web_id

end
