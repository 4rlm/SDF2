class Description < ApplicationRecord
  has_many :cont_descriptions, dependent: :destroy
  has_many :conts, through: :cont_descriptions

  validates_uniqueness_of :job_desc, allow_blank: true, allow_nil: true

end
