require 'spec_helper'

feature 'Social networking' do
  given(:alice) { Fabricate(:user, name: 'Alice') }
  given(:bob) { Fabricate(:user, name: 'Bob') }
  given(:archer) { Fabricate(:video, small_cover_url: "/tmp/archer.jpg") }
  background do
    Fabricate(:review, video: archer, user: bob)
  end
  scenario 'User follows and unfollows another user' do
    sign_in(alice)

    click_on_video_from_home_page(archer)

    follow_user_from_video_page(bob)
    
    click_link "People"
    expect(page).to have_text "People I Follow"
    expect(page).to have_text bob.name

    unfollow(bob)
    expect(page).to have_text "You are no longer following #{bob.name}."
  end

  def follow_user_from_video_page(user)
    click_link user.name
    click_link "Follow"
  end

  def unfollow(user)
    find("a[data-method='delete']").click
  end
end