module QueriesHelper


  def follow_all_query_helper(query_id)
    query = Query.find(query_id)
    if query.mod_name == 'Cont'
      cont_ids = Cont.ransack(query.params['q']).result(distinct: true).includes(:acts, :web, :brands, :act_activities, :cont_activities, :web_activities).pluck(:id)
      current_user.cont_activities.unfollowed.where(cont_id: [cont_ids]).update_all(fav_sts: true)
    elsif query.mod_name == 'Web'
      binding.pry
      web_ids = Web.ransack(query.params['q']).result(distinct: true).includes(:acts, :conts, :brands, :web_activities, :act_activities).pluck(:id)

      binding.pry
      activities = current_user.web_activities.unfollowed.where(web_id: [web_ids]).update_all(fav_sts: true)
    end
  end


  def unfollow_all_query_helper(query_id)
    query = Query.find(query_id)
    if query.mod_name == 'Cont'
      cont_ids = Cont.ransack(query.params['q']).result(distinct: true).includes(:acts, :web, :brands, :act_activities, :cont_activities, :web_activities).pluck(:id)
      current_user.cont_activities.followed.where(cont_id: [cont_ids]).update_all(fav_sts: false)
    elsif query.mod_name == 'Web'
      web_ids = Web.ransack(query.params['q']).result(distinct: true).includes(:acts, :conts, :brands, :web_activities, :act_activities).pluck(:id)
      current_user.web_activities.followed.where(web_id: [web_ids]).update_all(fav_sts: false)
    end
  end


  def hide_all_query_helper(query_id)
    query = Query.find(query_id)
    if query.mod_name == 'Cont'
      cont_ids = Cont.ransack(query.params['q']).result(distinct: true).includes(:acts, :web, :brands, :act_activities, :cont_activities, :web_activities).pluck(:id)
      current_user.cont_activities.unhidden.where(cont_id: [cont_ids]).update_all(hide_sts: true)
    elsif query.mod_name == 'Web'
      web_ids = Web.ransack(query.params['q']).result(distinct: true).includes(:acts, :conts, :brands, :web_activities, :act_activities).pluck(:id)
      current_user.web_activities.unhidden.where(web_id: [web_ids]).update_all(hide_sts: true)
    end
  end


  def unhide_all_query_helper(query_id)
    query = Query.find(query_id)
    if query.mod_name == 'Cont'
      cont_ids = Cont.ransack(query.params['q']).result(distinct: true).includes(:acts, :web, :brands, :act_activities, :cont_activities, :web_activities).pluck(:id)
      current_user.cont_activities.hidden.where(cont_id: [cont_ids]).update_all(hide_sts: false)
    elsif query.mod_name == 'Web'
      web_ids = Web.ransack(query.params['q']).result(distinct: true).includes(:acts, :conts, :brands, :web_activities, :act_activities).pluck(:id)
      current_user.web_activities.hidden.where(web_id: [web_ids]).update_all(hide_sts: false)
    end
  end


end
