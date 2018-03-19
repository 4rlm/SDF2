class Tracking < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :track

  validates :track_id, :uniqueness => { :scope => [:trackable_type, :trackable_id] }
end
