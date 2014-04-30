class ResetPasswordsController < ApplicationController
  before_action :require_no_user

  def show
    @user = User.find_by(token: params[:id])
    !!@user ? (render :show) : (redirect_to invalid_token_path)
  end

  def create
    @user = User.find_by(token: params[:token]) unless params[:token].nil?
    if @user
      @user.update(password: params[:password], token: nil)
      flash[:success] = "Your password was updated."
      redirect_to login_path
    else
      redirect_to invalid_token_path 
    end
  end

  def invalid_token
  end
end