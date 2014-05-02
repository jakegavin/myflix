require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

feature 'invites' do
  given!(:frank) { User.create(name: "Frank", email: "frank@gmail.com", password: "frank") }

  scenario 'user invites a new user who then signs in' do
    sign_in(frank)

    friend_name = 'Jenny'
    friend_email = Faker::Internet.email
    
    invite_friend(friend_name, friend_email)

    click_link 'Sign Out'
    expect(page).to have_text 'You have successfully logged out.'

    open_email(friend_email)
    current_email.click_link 'clicking here'

    fill_in 'Password', with: 'blahblah'
    click_button 'Sign Up'
    expect(page).to have_text "Welcome, #{friend_name}"

    click_link 'People'
    expect(page).to have_text frank.name

    click_link 'Sign Out'
    expect(page).to have_text 'You have successfully logged out.'

    sign_in(frank)
    click_link 'People'
    expect(page).to have_text friend_name

    clear_emails
  end

  private

  def invite_friend(name, email)
    visit invite_path
    fill_in "Friend's Name", with: name
    fill_in "Friend's Email Address", with: email
    fill_in "Invitation Message", with: 'Check this out!'
    click_button 'Send Invitation'
  end
end