class QueriesTool

  def follow_all_queries(current_user, query_id)
    query = Query.find(query_id)

    if query.mod_name == 'Act'
      acts = get_ransack_acts(query.params['q'])
      current_user.act_activities.unfollowed.by_act(acts).update_all(fav_sts: true)
    elsif query.mod_name == 'Cont'
      conts = get_ransack_conts(query.params['q'])
      current_user.cont_activities.unfollowed.by_cont(conts).update_all(fav_sts: true)
    elsif query.mod_name == 'Web'
      webs = get_ransack_webs(query.params['q'])
      current_user.web_activities.unfollowed.by_web(webs).update_all(fav_sts: true)
    end
  end


  def unfollow_all_queries(current_user, query_id)
    query = Query.find(query_id)

    if query.mod_name == 'Act'
      acts = get_ransack_acts(query.params['q'])
      current_user.act_activities.followed.by_act(acts).update_all(fav_sts: false)
    elsif query.mod_name == 'Cont'
      conts = get_ransack_conts(query.params['q'])
      current_user.cont_activities.followed.by_cont(conts).update_all(fav_sts: false)
    elsif query.mod_name == 'Web'
      webs = get_ransack_webs(query.params['q'])
      current_user.web_activities.followed.by_web(webs).update_all(fav_sts: false)
    end
  end


  def hide_all_queries(current_user, query_id)
    query = Query.find(query_id)

    if query.mod_name == 'Act'
      acts = get_ransack_acts(query.params['q'])
      current_user.act_activities.unhidden.by_act(acts).update_all(hide_sts: true)
    elsif query.mod_name == 'Cont'
      conts = get_ransack_conts(query.params['q'])
      current_user.cont_activities.unhidden.by_cont(conts).update_all(hide_sts: true)
    elsif query.mod_name == 'Web'
      webs = get_ransack_webs(query.params['q'])
      current_user.web_activities.unhidden.by_web(webs).update_all(hide_sts: true)
    end
  end


  def unhide_all_queries(current_user, query_id)
    query = Query.find(query_id)

    if query.mod_name == 'Act'
      acts = get_ransack_acts(query.params['q'])
      current_user.act_activities.hidden.by_act(acts).update_all(hide_sts: false)
    elsif query.mod_name == 'Cont'
      conts = get_ransack_conts(query.params['q'])
      current_user.cont_activities.hidden.by_cont(conts).update_all(hide_sts: false)
    elsif query.mod_name == 'Web'
      webs = get_ransack_webs(query.params['q'])
      current_user.web_activities.hidden.by_web(webs).update_all(hide_sts: false)
    end
  end


  def get_ransack_acts(params)
    acts = Act.ransack(params).result(distinct: true)
  end

  def get_ransack_conts(params)
    conts = Cont.ransack(params).result(distinct: true)
  end

  def get_ransack_webs(params)
    webs = Web.ransack(params).result(distinct: true)
  end


end
