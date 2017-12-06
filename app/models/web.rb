class Web < ApplicationRecord
  # has_many :account_webs, dependent: :destroy
  # has_many :accounts, through: :account_webs
  # validates_uniqueness_of :url, allow_blank: true, allow_nil: true

  ## DELETE ABOVE AFTER TESTING.  ALSO DELETE AccountWeb Table.  ###

  has_many :webings
  has_many :accounts, through: :webings, source: :webable, source_type: :Account
  has_many :contacts, through: :webings, source: :webable, source_type: :Contact
  validates_uniqueness_of :url, allow_blank: true, allow_nil: true
  # validates :url, uniqueness: true
  # accepts_nested_attributes_for :phone

end
