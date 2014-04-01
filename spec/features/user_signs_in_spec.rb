require 'spec_helper'

feature 'user signs in' do
  background do
    User.create(name: "Test User", email: "testing@gmail.com", password: "testing")
  end
  scenario 'with valid email and password' do
    visit login_path
    fill_in "Email Address", with: "testing@gmail.com"
    fill_in "Password", with: "testing"
    click_button "Sign in"
    expect(page).to have_text "Welcome, Test User"
  end
end