class Title < ApplicationRecord
  has_many :contact_titles, dependent: :destroy
  has_many :contacts, through: :contact_titles

  validates_uniqueness_of :job_title, allow_blank: true, allow_nil: true

end
