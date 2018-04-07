module QueriesHelper

  def follow_all_query_helper(query_id)
    query = Query.find(query_id)
    if query.mod_name == 'Cont'
      cont_ids = Cont.ransack(query.params['q']).result(distinct: true).includes(:acts, :web, :brands, :act_activities, :cont_activities, :web_activities)&.map(&:id)
      ContActivity.where(user_id: current_user.id, cont_id: [cont_ids]).update_all(fav_sts: true)
    elsif query.mod_name == 'Web'
      web_ids = Web.ransack(query.params['q']).result(distinct: true).includes(:acts, :conts, :brands, :web_activities, :act_activities)&.map(&:id)
      WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(fav_sts: true)
    end
  end

  def unfollow_all_query_helper(query_id)
    query = Query.find(query_id)
    if query.mod_name == 'Cont'
      cont_ids = Cont.ransack(query.params['q']).result(distinct: true).includes(:acts, :web, :brands, :act_activities, :cont_activities, :web_activities)&.map(&:id)
      ContActivity.where(user_id: current_user.id, cont_id: [cont_ids]).update_all(fav_sts: false)
    elsif query.mod_name == 'Web'
      web_ids = Web.ransack(query.params['q']).result(distinct: true).includes(:acts, :conts, :brands, :web_activities, :act_activities)&.map(&:id)
      WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(fav_sts: false)
    end
  end

  def hide_all_query_helper(query_id)
    query = Query.find(query_id)
    if query.mod_name == 'Cont'
      cont_ids = Cont.ransack(query.params['q']).result(distinct: true).includes(:acts, :web, :brands, :act_activities, :cont_activities, :web_activities)&.map(&:id)
      ContActivity.where(user_id: current_user.id, cont_id: [cont_ids]).update_all(hide_sts: true)
    elsif query.mod_name == 'Web'
      web_ids = Web.ransack(query.params['q']).result(distinct: true).includes(:acts, :conts, :brands, :web_activities, :act_activities)&.map(&:id)
      WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(hide_sts: true)
    end
  end

  def unhide_all_query_helper(query_id)
    query = Query.find(query_id)
    if query.mod_name == 'Cont'
      cont_ids = Cont.ransack(query.params['q']).result(distinct: true).includes(:acts, :web, :brands, :act_activities, :cont_activities, :web_activities)&.map(&:id)
      ContActivity.where(user_id: current_user.id, cont_id: [cont_ids]).update_all(hide_sts: false)
    elsif query.mod_name == 'Web'
      web_ids = Web.ransack(query.params['q']).result(distinct: true).includes(:acts, :conts, :brands, :web_activities, :act_activities)&.map(&:id)
      WebActivity.where(user_id: current_user.id, web_id: [web_ids]).update_all(hide_sts: false)
    end
  end

end
