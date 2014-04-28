class ForgotPasswordsController < ApplicationController
  before_action :require_no_user

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user
      user.generate_token!
      AppMailer.reset_password_link_email(user).deliver
      redirect_to password_reset_confirmation_path
    else
      if params[:email].blank? 
        flash[:danger] = "Email address cannot be blank."
      else
        flash[:danger] = "We couldn't find a user with that email address."
      end
      render :new
    end
  end

  def password_reset_confirmation
  end

  def invalid_token
  end
end