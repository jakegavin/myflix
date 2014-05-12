class UsersController < ApplicationController
  before_action :require_no_user, except: [:show]
  before_action :require_user, only: [:show]

  def new
    @user = User.new
    @invite = Invite.find_by(token: params[:token])
  end

  def create
    @user = User.new(user_params)
    @invite = Invite.find_by(token: params[:token])
    creation = UserCreation.new(@user, @invite, params[:stripeToken]).create_and_charge_user
    if creation.successful?
      flash[:success] = creation.message
      session[:user_id] = @user.id
      redirect_to home_path
    else
      flash[:danger] = creation.message
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    @queue_items = @user.queue_items
    @reviews = @user.reviews
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

  def create_relationships(user, invite)
    Relationship.create(user: user, followed_user: invite.inviter)
    Relationship.create(user: invite.inviter, followed_user: user)
  end

  def delete_invites(user)
    invites = Invite.where(email: user.email)
    invites.each do |invite|
      invite.destroy
    end
  end
end
