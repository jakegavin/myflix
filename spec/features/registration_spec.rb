require 'spec_helper'

feature 'User registration', { js: true, vcr: true } do    
  background { visit register_path }
  scenario 'user has valid inputs' do
    fill_in_bob
    fill_in_credit_card
    click_button 'Sign Up'
    expect(page).to have_content 'Welcome, Bob'
  end
  scenario 'user has invalid user attributes and valid credit card' do
    fill_in_bob(nil)
    fill_in_credit_card
    click_button 'Sign Up'
    expect(page).to have_content "can't be blank"
  end
  scenario 'user has valid user attributes and invalid credit card' do
    fill_in_bob
    fill_in_credit_card(nil)
    click_button 'Sign Up'
    expect(page).to have_content 'This card number looks invalid'
  end
  scenario 'user has valid attributes but credit card is declined' do
    fill_in_bob
    fill_in_credit_card('4000000000000002')
    click_button 'Sign Up'
    expect(page).to have_content 'Your card was declined.'
  end
  
  private

  def fill_in_bob(email='bob@gmail.com')
    fill_in 'Full Name', with: 'Bob'
    fill_in 'Email Address', with: email
    fill_in 'Password', with: 'password'
  end

  def fill_in_credit_card(card_number = '4242424242424242')
    fill_in 'Credit Card Number', with: card_number
    fill_in 'Security Code', with: '123'
    select '1 - January', from: 'date_month'
    select '2017', from: 'date_year'
  end
end
