class Phone < ApplicationRecord
  # has_many :phonings
  has_many :phonings, dependent: :destroy

  # has_many :accounts, through: :phonings, source: :phonable, source_type: :Account
  # has_many :contacts, through: :phonings, source: :phonable, source_type: :Contact
  has_many :accounts, through: :phonings, dependent: :destroy, source: :phonable, source_type: :Account
  has_many :contacts, through: :phonings, dependent: :destroy, source: :phonable, source_type: :Contact

  validates :phone, uniqueness: true
  # validates_uniqueness_of :phone, allow_blank: true, allow_nil: true

end
