class AdminController < AuthenticatedUserController

  before_action :require_admin

  def require_admin
    if !current_user.admin?
      flash[:danger] = 'You must be an administrator to do that.'
      redirect_to root_path
    end
  end

end