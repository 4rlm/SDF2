class ActivitiesController < ApplicationController

  # GET /toggle_sts
  def toggle_sts
    binding.pry
    activity = Activity.where(id: params[:activity_id]).update_all(fav_sts: params[:fav_sts])
    acty = Activity.find_by(id: params[:activity_id])
    binding.pry
    redirect_back fallback_location: root_path
  end

end
