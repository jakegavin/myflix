class AppMailer < ActionMailer::Base
  default from: 'Myflix <jakegavin@gmail.com>'

  def welcome_email(user)
    @user = user
    email_with_name = "#{@user.name} <#{@user.email}>"
    mail(to: email_with_name, subject: 'Welcome to Myflix' )
  end

  def reset_password_link_email(user)
    @user = user
    email_with_name = "#{@user.name} <#{@user.email}>"
    mail(to: email_with_name, subject: 'Myflix: Password reset request')
  end
end