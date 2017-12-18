class Link < ApplicationRecord

  has_many :linkings
  has_many :webs, through: :linkings, source: :linkable, source_type: :Web
  # has_many :linkings, dependent: :destroy
  # has_many :webs, through: :linkings, dependent: :destroy, source: :linkable, source_type: :Web

  validates :link, uniqueness: true
  # validates_uniqueness_of :link, allow_blank: true, allow_nil: true

end
