require 'spec_helper'

feature 'Add a video' do
  given!(:admin) { Fabricate(:admin, password: 'admin', admin: true) }
  given!(:comedy) { Fabricate(:category, name: 'Comedy') }
  scenario 'admin adds a video' do
    sign_in(admin)

    visit new_admin_video_path
    fill_in 'Title', with: 'A Great Video'
    check 'video_category_ids_1'
    fill_in 'Description', with: 'Its a very exciting video'
    attach_file 'Large cover', 'spec/support/uploads/adl.jpg'
    attach_file 'Small cover', 'spec/support/uploads/ads.jpg'
    fill_in 'Video URL', with: 'http://www.youtube.com'

    click_button 'Add Video'
    expect(Video.all.size).to eq(1)
    expect(Video.last.small_cover).to_not be_nil
    expect(Video.last.categories.size).to eq 1

    visit logout_path

    sign_in
    click_on_video_from_home_page(Video.last)

    expect(page).to have_text Video.last.description
    expect(page).to have_selector("a[href='http://www.youtube.com']")
  end
end