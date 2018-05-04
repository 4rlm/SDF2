class TalliesTool
# module TalliesHelper

  def generate_csv_tallies(current_user, params)
    if params[:mod_name] == 'Act'
      ActCsvTool.new.start_act_webs_csv_and_log(params, current_user)
    elsif params[:mod_name] == 'Cont'
      ContCsvTool.new.start_cont_web_csv_and_log(params, current_user)
    elsif params[:mod_name] == 'Web'
      WebCsvTool.new.start_web_acts_csv_and_log(params, current_user)
    end
  end


  def follow_all_tallies(current_user, params)
    if params[:mod_name] == 'Act'
      acts = Act.send(params[:tally_scope])
      current_user.act_activities.unfollowed.by_act(acts).update_all(fav_sts: true)
    elsif params[:mod_name] == 'Cont'
      conts = Cont.send(params[:tally_scope])
      current_user.cont_activities.unfollowed.by_cont(conts).update_all(fav_sts: true)
    elsif params[:mod_name] == 'Web'
      webs = Web.send(params[:tally_scope])
      current_user.web_activities.unfollowed.by_web(webs).update_all(fav_sts: true)
    end
  end


  def unfollow_all_tallies(current_user, params)
    if params[:mod_name] == 'Act'
      acts = Act.send(params[:tally_scope])
      current_user.act_activities.followed.by_act(acts).update_all(fav_sts: false)
    elsif params[:mod_name] == 'Cont'
      conts = Cont.send(params[:tally_scope])
      current_user.cont_activities.followed.by_cont(conts).update_all(fav_sts: false)
    elsif params[:mod_name] == 'Web'
      webs = Web.send(params[:tally_scope])
      current_user.web_activities.followed.by_web(webs).update_all(fav_sts: false)
    end
  end


  def hide_all_tallies(current_user, params)
    if params[:mod_name] == 'Act'
      acts = Act.send(params[:tally_scope])
      current_user.act_activities.unhidden.by_act(acts).update_all(hide_sts: true)
    elsif params[:mod_name] == 'Cont'
      conts = Cont.send(params[:tally_scope])
      current_user.cont_activities.unhidden.by_cont(conts).update_all(hide_sts: true)
    elsif params[:mod_name] == 'Web'
      webs = Web.send(params[:tally_scope])
      current_user.web_activities.unhidden.by_web(webs).update_all(hide_sts: true)
    end
  end


  def unhide_all_tallies(current_user, params)
    if params[:mod_name] == 'Act'
      acts = Act.send(params[:tally_scope])
      current_user.act_activities.hidden.by_act(acts).update_all(hide_sts: false)
    elsif params[:mod_name] == 'Cont'
      conts = Cont.send(params[:tally_scope])
      current_user.cont_activities.hidden.by_cont(conts).update_all(hide_sts: false)
    elsif params[:mod_name] == 'Web'
      webs = Web.send(params[:tally_scope])
      current_user.web_activities.hidden.by_web(webs).update_all(hide_sts: false)
    end
  end

end
