require 'spec_helper'

feature "Queue interaction" do

  given!(:south_park) { Fabricate(:video, title: "South Park", categories: [Fabricate(:category)], small_cover_url: "/tmp/sp.jpg", description: "An ongoing narrative revolving around four boys—Stan Marsh, Kyle Broflovski, Eric Cartman, and Kenny McCormick—and their bizarre adventures in and around the titular Colorado town." ) }
  given!(:futurama) { Fabricate(:video, title: "Futurama", categories: [Fabricate(:category)], description: "A pizza delivery boy awakens in the 31st century after 1,000 years of cryogenic preservation and finds a job at an interplanetary delivery service.", small_cover_url: "/tmp/futurama.jpg") }
  given!(:archer) { Fabricate(:video, title: "Archer", categories: [Fabricate(:category)], description: "Sophisticated spy Archer may have the coolest gadgets, but he still has issues when it comes to dealing with his boss -- who also is his mother.", small_cover_url: "/tmp/archer.jpg") }
  given!(:jake) { Fabricate(:user, name: "Jake Gavin", email: "jakegavin@gmail.com", password: "jakegavin") }

  scenario "User adds and reorders queue items" do
    sign_in(jake)
    expect(page).to have_text "Welcome, Jake Gavin"

    add_video_to_queue(south_park)
    expect(page).to have_content south_park.title
    expect(page).to have_text "List Order"
    expect(page).to have_text "Video Title"

    click_link "South Park"

    expect(page).to have_text south_park.description
    expect_link_to_not_be_seen("+ My Queue")

    add_video_to_queue(futurama)
    add_video_to_queue(archer)

    expect_queue_to_have_videos([south_park, futurama, archer])
    expect(find('#item_0_title')).to have_text south_park.title
    expect(find('#item_1_title')).to have_text futurama.title
    expect(find('#item_2_title')).to have_text archer.title

    fill_in_video_position(south_park, 4)
    fill_in_video_position(futurama, 3)
    fill_in_video_position(archer, 5)
    click_button ('Update Instant Queue')

    expect(find("input[data-pos-video-id='#{futurama.id}']").value).to eq "1"
    expect(find('#item_0_title')).to have_text futurama.title
    expect(find("input[data-pos-video-id='#{south_park.id}']").value).to eq "2"
    expect(find('#item_1_title')).to have_text south_park.title
    expect(find("input[data-pos-video-id='#{archer.id}']").value).to eq "3"
    expect(find('#item_2_title')).to have_text archer.title
  end

  def expect_link_to_not_be_seen(link_text)
    expect(page).to_not have_content link_text
  end

  def expect_queue_to_have_videos(videos)
    visit queue_path
    videos.each do |video|
      expect(page).to have_text video.title
    end
  end

  def fill_in_video_position(video, position) do
    find("input[data-pos-video-id='#{video.id}']").set(position)
  end

  def add_video_to_queue(video)
    visit home_path
    find(:xpath, "//a/img[@src='#{video.small_cover_url}']/ancestor::a[1]").click
    click_link "+ My Queue"
  end


end