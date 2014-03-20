class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user and user.authenticate(params[:password])
      flash[:success] = "You have logged in."
      session[:user_id] = user.id
      redirect_to home_path
    else
      flash[:danger] = "Incorrect email or password. Please try again."
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "You have successfully logged out."
    redirect_to root_path
  end
end