class Track < ApplicationRecord
  belongs_to :user

  has_many :trackings
  has_many :acts, through: :trackings, source: :trackable, source_type: :act
  has_many :webs, through: :trackings, source: :trackable, source_type: :web
  has_many :conts, through: :trackings, source: :trackable, source_type: :cont
end
