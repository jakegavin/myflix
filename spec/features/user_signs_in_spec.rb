require 'spec_helper'

feature 'user signs in' do
  given!(:user) { User.create(name: "Test User", email: "testing@gmail.com", password: "testing") }

  scenario 'with valid email and password' do
    sign_in(user)
    expect(page).to have_text "Welcome, Test User"
  end
end