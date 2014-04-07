class RelationshipsController < ApplicationController
  before_action :require_user
  def index
    @relationships = current_user.relationships
  end

  def create
    if current_user.can_follow?(User.find(params[:followed_id]))
      @relationship = Relationship.create(user: current_user, followed_id: params[:followed_id])
      flash[:success] = "You are now following #{@relationship.followed_user.name}"
    end
    redirect_to following_path
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    if @relationship.user == current_user
      flash[:success] = "You are no longer following #{@relationship.followed_user.name}"
      @relationship.destroy
    else
      flash[:danger] = "There was an error with your request."
    end
    redirect_to following_path
  end
end