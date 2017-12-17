class Text < ApplicationRecord
  has_many :textings
  # has_many :textings, dependent: :destroy
  has_many :webs, through: :textings, source: :textable, source_type: :Web
  # has_many :webs, through: :textings, dependent: :destroy, source: :textable, source_type: :Web


  validates :text, uniqueness: true
  # validates_uniqueness_of :text, allow_blank: true, allow_nil: true

end
