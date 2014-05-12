class UserCreation
  attr_accessor :user, :invite, :stripe_token, :status, :message
  def initialize(user, invite=nil, stripe_token=nil)
    @user = user
    @invite = invite
    @stripe_token = stripe_token
  end

  def create_and_charge_user
    if user.valid?
      charge = StripeWrapper::Charge.create(amount: 999, card: stripe_token)
      if charge.successful?
        user.save
        create_relationships if invite
        delete_invites
        AppMailer.welcome_email(user).deliver
        @message = "Your account was created."
        @status = :success
      else
        @message = charge.error_message
        @status = :fail
      end
    else
      @status = :fail
    end
    self
  end

  def successful?
    status == :success
  end

  private

  def create_relationships
    Relationship.create(user: user, followed_user: invite.inviter)
    Relationship.create(user: invite.inviter, followed_user: user)
  end

  def delete_invites
    invites = Invite.where(email: user.email)
    invites.each do |invite|
      invite.destroy
    end
  end
end
