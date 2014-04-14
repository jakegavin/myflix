require 'spec_helper'

feature "Reset password" do
  let!(:bob) { Fabricate(:user, name: "Bob", email: "bob@gmail.com") }
  scenario "reset password and signs in with new password" do
    
    send_reset_password_email(bob.email)

    open_email(bob.email)
    current_email.click_link "click here"
    
    new_password = "new_password"
    fill_in "New Password", with: new_password
    click_button "Reset Password"
    expect(page).to have_text "Your password was updated."
    expect(page).to have_text "Sign in"

    verify_sign_in_with_user_and_password(bob, new_password)
  end

  private

  def send_reset_password_email(email)
    visit root_path
    click_link "sign in"

    click_link "Forgot your password?"

    fill_in "Email Address", with: email
    click_button "Send Email"
  end


  def verify_sign_in_with_user_and_password(user, password)
    visit login_path
    fill_in "Email Address", with: user.email
    fill_in "Password", with: password
    click_button "Sign in"
    expect(page).to have_text "Welcome, #{user.name}"
  end
end