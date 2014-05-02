class AppMailer < ActionMailer::Base
  default from: 'Myflix <jakegavin@gmail.com>'

  def welcome_email(user)
    @user = user
    mail(to: email_with_name, subject: 'Welcome to Myflix' )
  end

  def reset_password_link_email(user)
    @user = user
    mail(to: email_with_name, subject: 'Myflix: Password reset request')
  end

  def invite_email(user, invite)
    @invite = invite
    @sender = user
    mail(to: email_with_name, subject: "#{@sender.name} sent you a Myflix invitation")
  end

  private

  def email_with_name
    if Rails.env.staging?
      return "Myflix Staging Email <#{ENV['STAGING_EMAIL_RECIPIENT']}>"
    else
      return "#{@invite.name} <#{@invite.email}>"
    end
  end
end