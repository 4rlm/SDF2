class WebActivity < ApplicationRecord
  belongs_to :user
  belongs_to :web
  validates_uniqueness_of :web_id, scope: [:user_id]
  # belongs_to :export

  # Query below:
  # user.web_activities.followed_webs.count
  scope :followed, ->{ where(fav_sts: true) }
  scope :unfollowed, ->{ where(fav_sts: false) }
  scope :hidden, ->{ where(hide_sts: true) }
  scope :unhidden, ->{ where(hide_sts: false) }

  scope :by_web, ->(web) { where(web_id: web) }
  # web_activities = current_user.web_activities.by_web(webs)

  def self.create_user_web_activities(current_user)
    ActivitiesTool.new.delay(priority: 0).create_web_activities(current_user.id)
  end

  def self.unfollow_unhide_webs(action, current_user)
    if action == 'unfollow'
      ActivitiesTool.new.delay(priority: 0).unfollow_all_webs(current_user)
    elsif action == 'unhide'
      ActivitiesTool.new.delay(priority: 0).unhide_all_webs(current_user)
    end
  end

end
