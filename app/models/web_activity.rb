class WebActivity < ApplicationRecord
  belongs_to :user
  belongs_to :web
  # belongs_to :export

  # Query below:
  # user.web_activities.followed_webs.count
  scope :followed, ->{ where(fav_sts: true) }
  scope :unfollowed, ->{ where(fav_sts: false) }
  scope :hidden, ->{ where(hide_sts: true) }
  scope :unhidden, ->{ where(hide_sts: false) }

  validates_uniqueness_of :web_id, scope: [:user_id]
end
