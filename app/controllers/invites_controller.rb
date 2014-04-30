class InvitesController < ApplicationController
  before_action :require_user

  def new
    @invite = Invite.new
  end

  def create
    @invite = Invite.new(invite_params)
    @invite.inviter = current_user
    if @invite.save
      flash[:success] = "Invite sent to #{@invite.name} <#{@invite.email}>"
      AppMailer.invite_email(current_user, @invite).deliver
      redirect_to home_path
    else
      render :new
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:name, :email, :message)
  end
end
