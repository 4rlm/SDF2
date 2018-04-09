class ActActivity < ApplicationRecord
  belongs_to :user
  belongs_to :act
  # belongs_to :export

  # Query below:
  # user.act_activities.followed_acts.count
  scope :followed, ->{ where(fav_sts: true) }
  scope :unfollowed, ->{ where(fav_sts: false) }
  scope :hidden, ->{ where(hide_sts: true) }
  scope :unhidden, ->{ where(hide_sts: false) }

  validates_uniqueness_of :act_id, scope: [:user_id]
end
