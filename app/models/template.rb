class Template < ApplicationRecord

  has_many :templatings
  # has_many :accounts, through: :templatings, source: :templatable, source_type: :Account
  has_many :webs, through: :templatings, source: :templatable, source_type: :Web

  validates_uniqueness_of :template_name, allow_blank: true, allow_nil: true

end
