require 'spec_helper'

feature 'registration', { js: true, vcr: true}  do
  scenario 'user has valid inputs' do
    visit register_path
    fill_in 'Full Name', with: 'Bob'
    fill_in 'Email Address', with: 'bob@gmail.com'
    fill_in 'Password', with: 'password'

    fill_in 'Credit Card Number', with: '4242424242424242'
    fill_in 'Security Code', with: '123'
    select '1 - January', from: 'date_month'
    select '2017', from: 'date_year'

    click_button 'Sign Up'
  end
end