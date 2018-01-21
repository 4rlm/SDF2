class Template < ApplicationRecord

  has_many :templatings
  # has_many :acts, through: :templatings, source: :templatable, source_type: :Act
  has_many :webs, through: :templatings, source: :templatable, source_type: :Web

  validates_uniqueness_of :temp_name, allow_blank: true, allow_nil: true

end
