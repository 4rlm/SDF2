class Description < ApplicationRecord
  has_many :contact_descriptions, dependent: :destroy
  has_many :contacts, through: :contact_descriptions

  validates_uniqueness_of :job_description, allow_blank: true, allow_nil: true

end
