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

  def self.create_user_act_activities(current_user)
    ActivitiesTool.new.delay(priority: 0).create_act_activities(current_user.id)
  end


  def self.unfollow_unhide_acts(action, current_user)
    if action == 'unfollow'
      ActivitiesTool.new.delay(priority: 0).unfollow_all_acts(current_user)
    elsif action == 'unhide'
      ActivitiesTool.new.delay(priority: 0).unhide_all_acts(current_user)
    end
  end

end
