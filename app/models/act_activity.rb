class ActActivity < ApplicationRecord
  belongs_to :user
  belongs_to :act
  # belongs_to :export

  validates_uniqueness_of :act_id, scope: [:user_id]
end
