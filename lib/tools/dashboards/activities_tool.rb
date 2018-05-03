class ActivitiesTool

  def create_web_activities(user_id)
    web_ids = Web.all.order("created_at DESC").pluck(:id) - WebActivity.where(user_id: user_id).pluck(:web_id)
    headers = [:user_id, :web_id]
    rows = web_ids.map { |web_id| [user_id, web_id] }
    WebActivity.import(headers, rows, validate: false)
  end

  def create_act_activities(user_id)
    act_ids = Act.all.order("created_at DESC").pluck(:id) - ActActivity.where(user_id: user_id).pluck(:act_id)
    headers = [:user_id, :act_id]
    rows = act_ids.map { |act_id| [user_id, act_id] }
    ActActivity.import(headers, rows, validate: false)
  end

  def create_cont_activities(user_id)
    cont_ids = Cont.all.order("created_at DESC").pluck(:id) - ContActivity.where(user_id: user_id).pluck(:cont_id)
    headers = [:user_id, :cont_id]
    rows = cont_ids.map { |cont_id| [user_id, cont_id] }
    ContActivity.import(headers, rows, validate: false)
  end


  ### UNFOLLOW/UNHIDE FOR ACT/CONT/WEB_ACTIVITIES - BELOW ######

  def unfollow_all_acts(current_user)
    current_user.act_activities.followed.update_all(fav_sts: false)
  end

  def unhide_all_acts(current_user)
    current_user.act_activities.hidden.update_all(hide_sts: false)
  end


  def unfollow_all_conts(current_user)
    current_user.cont_activities.followed.update_all(fav_sts: false)
  end


  def unhide_all_conts(current_user)
    current_user.cont_activities.hidden.update_all(hide_sts: false)
  end


  def unfollow_all_webs(current_user)
    current_user.web_activities.followed.update_all(fav_sts: false)
  end


  def unhide_all_webs(current_user)
    current_user.web_activities.hidden.update_all(hide_sts: false)
  end

  ### UNFOLLOW/UNHIDE FOR ACT/CONT/WEB_ACTIVITIES - ABOVE ######

end
