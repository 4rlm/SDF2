class ActivitiesController < ApplicationController

  # GET /toggle_sts
  def toggle_sts
    activity = Activity.where(id: params[:activity_id]).update_all(fav_sts: params[:fav_sts])
    redirect_back fallback_location: root_path
  end

end
