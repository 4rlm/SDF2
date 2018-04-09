class ContActivity < ApplicationRecord
  belongs_to :user
  belongs_to :cont
  # belongs_to :export

  # Query below:
  # user.cont_activities.followed.count
  scope :followed, ->{ where(fav_sts: true) }
  scope :unfollowed, ->{ where(fav_sts: false) }
  scope :hidden, ->{ where(hide_sts: true) }
  scope :unhidden, ->{ where(hide_sts: false) }

  validates_uniqueness_of :cont_id, scope: [:user_id]
end
