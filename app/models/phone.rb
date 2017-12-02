class Phone < ApplicationRecord
  validates :phone, uniqueness: true
  has_many :phonings
  has_many :accounts, through: :phonings, source: :phonable, source_type: :Account
  has_many :contacts, through: :phonings, source: :phonable, source_type: :Contact

  # accepts_nested_attributes_for :phone

end
