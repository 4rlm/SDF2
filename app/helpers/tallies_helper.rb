module TalliesHelper

  def follow_all_tally_helper(params)
    if params[:mod_name] == 'Act'
      act_ids = Act.send(params[:tally_scope]).pluck(:id)
      ActActivity.where(user_id: current_user.id, act_id: [act_ids]).update_all(fav_sts: true)
    elsif params[:mod_name] == 'Cont'
      cont_ids = Cont.send(params[:tally_scope]).pluck(:id)
      ContActivity.where(user_id: current_user.id, cont_id: [cont_ids]).update_all(fav_sts: true)
    elsif params[:mod_name] == 'Web'
      web_ids = Web.send(params[:tally_scope]).pluck(:id)
      WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(fav_sts: true)
    end
  end


  def unfollow_all_tally_helper(params)
    if params[:mod_name] == 'Act'
      act_ids = Act.send(params[:tally_scope]).pluck(:id)
      ActActivity.where(user_id: current_user.id, act_id: [act_ids]).update_all(fav_sts: false)
    elsif params[:mod_name] == 'Cont'
      cont_ids = Cont.send(params[:tally_scope]).pluck(:id)
      ContActivity.where(user_id: current_user.id, cont_id: [cont_ids]).update_all(fav_sts: false)
    elsif params[:mod_name] == 'Web'
      web_ids = Web.send(params[:tally_scope]).pluck(:id)
      WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(fav_sts: false)
    end
  end


  def hide_all_tally_helper(params)
    if params[:mod_name] == 'Act'
      act_ids = Act.send(params[:tally_scope]).pluck(:id)
      ActActivity.where(user_id: current_user.id, act_id: [act_ids]).update_all(hide_sts: true)
    elsif params[:mod_name] == 'Cont'
      cont_ids = Cont.send(params[:tally_scope]).pluck(:id)
      ContActivity.where(user_id: current_user.id, cont_id: [cont_ids]).update_all(hide_sts: true)
    elsif params[:mod_name] == 'Web'
      web_ids = Web.send(params[:tally_scope]).pluck(:id)
      WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(hide_sts: true)
    end
  end


  def unhide_all_tally_helper(params)
    if params[:mod_name] == 'Act'
      act_ids = Act.send(params[:tally_scope]).pluck(:id)
      ActActivity.where(user_id: current_user.id, act_id: [act_ids]).update_all(hide_sts: false)
    elsif params[:mod_name] == 'Cont'
      cont_ids = Cont.send(params[:tally_scope]).pluck(:id)
      ContActivity.where(user_id: current_user.id, cont_id: [cont_ids]).update_all(hide_sts: false)
    elsif params[:mod_name] == 'Web'
      web_ids = Web.send(params[:tally_scope]).pluck(:id)
      WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(hide_sts: false)
    end
  end

end
