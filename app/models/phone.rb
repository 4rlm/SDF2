class Phone < ApplicationRecord
  # has_many :phonings
  has_many :phonings, dependent: :destroy

  # has_many :acts, through: :phonings, source: :phonable, source_type: :Act
  # has_many :conts, through: :phonings, source: :phonable, source_type: :Cont
  has_many :acts, through: :phonings, dependent: :destroy, source: :phonable, source_type: :Act
  has_many :conts, through: :phonings, dependent: :destroy, source: :phonable, source_type: :Cont

  validates :phone, uniqueness: true
  # validates_uniqueness_of :phone, allow_blank: true, allow_nil: true


  UNRANSACKABLE_ATTRIBUTES = %w(id created_at updated_at)
  def self.ransackable_attributes auth_object = nil
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end


end
