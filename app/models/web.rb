class Web < ApplicationRecord
  has_many :account_webs, dependent: :destroy
  has_many :accounts, through: :account_webs

  validates_uniqueness_of :url, allow_blank: true, allow_nil: true

end
