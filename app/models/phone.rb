class Phone < ApplicationRecord
  has_many :phonings
  has_many :accounts, through: :phonings, source: :phonable, source_type: :Account
  has_many :contacts, through: :phonings, source: :phonable, source_type: :Contact

  validates :phone, uniqueness: true
  # accepts_nested_attributes_for :phone

end
