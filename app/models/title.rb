class Title < ApplicationRecord
  has_many :cont_titles, dependent: :destroy
  has_many :conts, through: :cont_titles

  validates_uniqueness_of :job_title, allow_blank: true, allow_nil: true

end
