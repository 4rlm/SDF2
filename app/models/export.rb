class Export < ApplicationRecord
  belongs_to :user
  has_many :exportings
  has_many :acts, through: :exportings, source: :exportable, source_type: :Act
  has_many :webs, through: :exportings, source: :exportable, source_type: :Web
  has_many :conts, through: :exportings, source: :exportable, source_type: :Cont
end
