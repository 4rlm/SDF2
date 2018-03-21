class Export < ApplicationRecord
  belongs_to :user
  has_many :exportings
  has_many :acts, through: :exportings, source: :exportable, source_type: :act
  has_many :webs, through: :exportings, source: :exportable, source_type: :web
  has_many :conts, through: :exportings, source: :exportable, source_type: :cont
end
