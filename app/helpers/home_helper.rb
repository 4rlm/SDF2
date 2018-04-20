module HomeHelper

  def basic_and_up
    current_user && (current_user.basic? || current_user.intermediate? || current_user.advanced? || current_user.admin?)
  end

  def intermediate_and_up
    current_user && (current_user.intermediate? || current_user.advanced? || current_user.admin?)
  end

  def advanced_and_up
    current_user && (current_user.advanced? || current_user.admin?)
  end

  def admin_only
    current_user && current_user.admin?
  end

end
