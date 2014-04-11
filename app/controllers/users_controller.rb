class UsersController < ApplicationController
  before_action :require_no_user, except: [:show]
  before_action :require_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Your account was created."
      session[:user_id] = @user.id
      AppMailer.welcome_email(@user).deliver
      redirect_to home_path
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    @queue_items = @user.queue_items
    @reviews = @user.reviews
  end

  def forgot_password
  end

  def generate_token
    user = User.find_by(email: params[:email])
    if user
      token = SecureRandom.urlsafe_base64
      user.password_reset_token = token
      user.save
      AppMailer.reset_password_link_email(user).deliver
      redirect_to password_reset_confirmation_path
    else
      flash[:danger] = "We couldn't find a user with that email address."
      render :forgot_password
    end
  end

  def reset_password
    if request.get?
      @user = User.find_by(password_reset_token: params[:password_reset_token]) unless params[:password_reset_token].nil?
      if @user
        render :reset_password
      else
        redirect_to invalid_token_path
      end
    elsif request.post?
      @user = User.find_by(password_reset_token: params[:password_reset_token]) unless params[:password_reset_token].nil?
      if @user.update(password: params[:password])
        @user.password_reset_token = nil
        @user.save
        flash[:success] = "Your password was updated"
        redirect_to login_path
      else
        render :reset_password
      end
    end
    # add password reset token column to the user table
    # Check params[:password_reset_token] and redirect to invalid token if it cant find a user with that token
    # Set password reset token to nil after user changes their password
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end