class Web < ApplicationRecord

  has_many :webings
  has_many :accounts, through: :webings, source: :webable, source_type: :Account
  has_many :contacts, through: :webings, source: :webable, source_type: :Contact
  has_many :whos, through: :webings, source: :webable, source_type: :Who

  has_many :textings, as: :textable
  has_many :texts, through: :textings
  accepts_nested_attributes_for :textings, :texts

  has_many :linkings, as: :linkable
  has_many :links, through: :linkings
  accepts_nested_attributes_for :linkings, :links

  has_many :templatings, as: :templatable
  has_many :templates, through: :templatings
  accepts_nested_attributes_for :templatings, :templates


  validates_uniqueness_of :url, allow_blank: true, allow_nil: true
  # validates :url, uniqueness: true
  # accepts_nested_attributes_for :phone

end
