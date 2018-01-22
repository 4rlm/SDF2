class Web < ApplicationRecord

  has_many :webings
  has_many :acts, through: :webings, source: :webable, source_type: :Act
  has_many :conts, through: :webings, source: :webable, source_type: :Cont
  has_many :whos, through: :webings, source: :webable, source_type: :Who

  has_many :textings, as: :textable
  has_many :texts, through: :textings
  accepts_nested_attributes_for :textings, :texts

  has_many :linkings, as: :linkable
  has_many :links, through: :linkings
  accepts_nested_attributes_for :linkings, :links

  validates_uniqueness_of :url, allow_blank: false, allow_nil: false
  # validates :url, uniqueness: true
  # accepts_nested_attributes_for :phone

end
