class Web < ApplicationRecord

  has_many :webings
  has_many :accounts, through: :webings, source: :webable, source_type: :Account
  has_many :contacts, through: :webings, source: :webable, source_type: :Contact

  has_many :whos, through: :webings, source: :webable, source_type: :Who

  validates_uniqueness_of :url, allow_blank: true, allow_nil: true
  # validates :url, uniqueness: true
  # accepts_nested_attributes_for :phone

end
