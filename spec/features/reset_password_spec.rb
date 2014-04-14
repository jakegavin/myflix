require 'spec_helper'

feature "Reset password" do
  let!(:bob) { Fabricate(:user, name: "Bob", email: "bob@gmail.com") }
  scenario "reset password then login with new password" do
    visit root_path
  end
end