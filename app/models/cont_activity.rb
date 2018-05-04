class ContActivity < ApplicationRecord
  belongs_to :user
  belongs_to :cont
  # belongs_to :export
  validates_uniqueness_of :cont_id, scope: [:user_id]

  # Query below:
  # user.cont_activities.followed.count
  scope :followed, ->{ where(fav_sts: true) }
  scope :unfollowed, ->{ where(fav_sts: false) }
  scope :hidden, ->{ where(hide_sts: true) }
  scope :unhidden, ->{ where(hide_sts: false) }

  scope :by_user, ->(user) { where(user_id: user.id) }
  # c = ContActivity.by_user(User.first)

  scope :by_cont, ->(cont) { where(cont_id: cont) }
  # cont_activities = current_user.cont_activities.by_cont(conts)


  def self.create_user_cont_activities(current_user)
    ActivitiesTool.new.delay(priority: 0).create_cont_activities(current_user.id)
  end

  def self.unfollow_unhide_conts(action, current_user)
    if action == 'unfollow'
      ActivitiesTool.new.delay(priority: 0).unfollow_all_conts(current_user)
    elsif action == 'unhide'
      ActivitiesTool.new.delay(priority: 0).unhide_all_conts(current_user)
    end
  end

end
