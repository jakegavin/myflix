require 'spec_helper'

feature 'User registration', { js: true } do    
  scenario 'user has valid inputs', driver: :selenium do
    visit register_path
    fill_in 'Full Name', with: 'Bob'
    fill_in 'Email Address', with: 'bob@gmail.com'
    fill_in 'Password', with: 'password'

    fill_in 'Credit Card Number', with: '4242424242424242'
    fill_in 'Security Code', with: '123'
    select '1 - January', from: 'date_month'
    select '2017', from: 'date_year'

    click_button 'Sign Up'
    expect(page).to have_text 'Welcome, Bob'
  end
  # scenario 'user has invalid user attributes and valid credit card'
  # scenario 'user has valid user attributes and invalid credit card'
  # scenario 'user has valid attributes but credit card is declined'
end

