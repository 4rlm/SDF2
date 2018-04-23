class AdminController < ApplicationController
  # before_action :admin_only
  # before_action :basic_and_up


  def index
    @pending_users =  User.where(role: "pending")
    @basic_users =  User.where(role: "basic")
    @intermediate_users =  User.where(role: "intermediate")
    @advanced_users =  User.where(role: "advanced")
    @admin_users =  User.where(role: "admin")
  end

  def starters
  end

  def developer
  end

  def change_user_level
    ids = params[:users]
    level = params[:level]
    level_chart = {"pending" => 0, "basic" => 1, "intermediate" => 2, "advanced" => 3, "admin" => 4}

    ids.each do |id|
      user = User.find(id)
      user.update_attribute(:role, level_chart[level])
    end
  end

  def delete_user
    user = User.find(params[:user])
    binding.pry
    user.act_activities.delete_all
    ActActivity.where(user_id: user.id).delete_all
    user.act_activities.delete_all
    user.destroy
    redirect_to admin_index_path
  end
end
