require 'spec_helper'

feature "Queue interaction" do

  given!(:south_park) { Fabricate(:video, title: "South Park", categories: [Fabricate(:category)], small_cover_url: "/tmp/sp.jpg", description: "An ongoing narrative revolving around four boys—Stan Marsh, Kyle Broflovski, Eric Cartman, and Kenny McCormick—and their bizarre adventures in and around the titular Colorado town." ) }
  given!(:futurama) { Fabricate(:video, title: "Futurama", categories: [Fabricate(:category)], description: "A pizza delivery boy awakens in the 31st century after 1,000 years of cryogenic preservation and finds a job at an interplanetary delivery service.", small_cover_url: "/tmp/futurama.jpg") }
  given!(:archer) { Fabricate(:video, title: "Archer", categories: [Fabricate(:category)], description: "Sophisticated spy Archer may have the coolest gadgets, but he still has issues when it comes to dealing with his boss -- who also is his mother.", small_cover_url: "/tmp/archer.jpg")}

  background do
    Fabricate(:user, name: "Jake Gavin", email: "jakegavin@gmail.com", password: "jakegavin")
  end

  scenario "User adds and reorders queue items" do
    visit root_path
    click_link "sign in"
    
    expect(page).to have_text "Sign in"
    
    fill_in "Email Address", with: "jakegavin@gmail.com"
    fill_in "Password", with: "jakegavin"
    click_button("Sign in")

    expect(page).to have_text "Welcome, Jake Gavin"

    find(:xpath, "//a/img[@src='#{south_park.small_cover_url}']/ancestor::a[1]").click

    expect(page).to have_text south_park.description

    click_link "+ My Queue"
    
    expect(page).to have_text "List Order"
    expect(page).to have_text "Video Title"

    click_link "South Park"

    expect(page).to have_text south_park.description
    expect(page).to_not have_text "+ My Queue"

    click_link "Videos"
    find(:xpath, "//a/img[@src='#{futurama.small_cover_url}']/ancestor::a[1]").click
    click_link "+ My Queue"

    click_link "Videos"
    find(:xpath, "//a/img[@src='#{archer.small_cover_url}']/ancestor::a[1]").click
    click_link "+ My Queue"

    expect(page).to have_text south_park.title
    expect(page).to have_text futurama.title
    expect(page).to have_text archer.title

    find('#item_0_title').should have_text south_park.title
    find('#item_1_title').should have_text futurama.title
    find('#item_2_title').should have_text archer.title

    fill_in 'item_0_position', with: '4'
    fill_in 'item_1_position', with: '3'
    fill_in 'item_2_position', with: '5'
    click_button ('Update Instant Queue')

    expect(find_field('item_0_position').value).to eq "1"
    expect(find('#item_0_title')).to have_text futurama.title
    expect(find_field('item_1_position').value).to eq "2"
    expect(find('#item_1_title')).to have_text south_park.title
    expect(find_field('item_2_position').value).to eq "3"
    expect(find('#item_2_title')).to have_text archer.title
  end
end