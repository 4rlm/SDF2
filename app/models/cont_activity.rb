class ContActivity < ApplicationRecord
  belongs_to :user
  belongs_to :cont
  # belongs_to :export

  validates_uniqueness_of :cont_id, scope: [:user_id]
end
