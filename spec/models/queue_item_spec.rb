require 'spec_helper'

describe QueueItem do
  it { should belong_to(:user) }
  it { should belong_to(:video) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:video_id) }
  it { should validate_numericality_of(:position).only_integer }

  describe '#video_title' do
    let (:video) { Fabricate(:video) }
    let (:qi) { Fabricate(:queue_item, video: video)}
    it 'returns the video title' do 
      expect(qi.video_title).to eq(video.title)
    end
  end

  describe '#rating' do
    let (:user) { Fabricate(:user) }
    let (:video) { Fabricate(:video) }
    let (:qi) { Fabricate(:queue_item, video: video, user: user)}
    it 'returns empty string if there are no ratings by the associated user' do
      expect(qi.rating).to eq("")
    end
    it 'returns the video rating if one review rating by the associated user' do
      Fabricate(:review, user: user, video: video, rating: 4)
      expect(qi.rating).to eq(4)
    end

    it 'returns the most recent rating if multiple reviews by the associated user' do
      Fabricate(:review, user: user, video: video, rating: 3, created_at: 2.days.ago)
      Fabricate(:review, user: user, video: video, rating: 5, created_at: 1.day.ago)
      expect(qi.rating).to eq(5)
    end
  end

  describe '#genres' do
    let (:user) { Fabricate(:user) }
    let (:cat1) { Fabricate(:category) }
    it 'returns an array with one category if one category' do 
      video = Fabricate(:video, categories: [cat1])
      qi = Fabricate(:queue_item, video: video, user: user)
      expect(qi.genres).to eq([cat1])
    end
    it 'returns an array of video categories if many categories' do
      cat2 = Fabricate(:category)
      cat3 = Fabricate(:category)
      video = Fabricate(:video, categories: [cat3, cat1, cat2])
      qi = Fabricate(:queue_item, video: video, user: user)
      expect(qi.genres).to eq([cat3, cat1, cat2])
    end
  end
end