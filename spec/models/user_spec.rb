require 'spec_helper'

describe User do
  it { should have_many(:reviews).order("created_at DESC") }
  it { should have_many(:queue_items) }
  it { should have_many(:followed_users) }
  it { should have_many(:followers) }
  
  describe "::reviews" do
    it "should return an empty array if user has no reviews" do
      user = Fabricate(:user)
      expect(user.reviews).to eq([])
    end
    it "should return the user's reviews if user has reviews" do
      user = Fabricate(:user)
      rev1 = Fabricate(:review, user: user, created_at: 1.day.ago)
      rev2 = Fabricate(:review, user: user, created_at: 30.seconds.ago)
      rev3 = Fabricate(:review, user: user, created_at: 3.days.ago)
      expect(user.reviews.length).to eq(3)
    end
    it "returns reviews in reverse chronological order" do
      user = Fabricate(:user)
      rev1 = Fabricate(:review, user: user, created_at: 2.days.ago)
      rev2 = Fabricate(:review, user: user, created_at: 1.day.ago)
      rev3 = Fabricate(:review, user: user, created_at: 3.days.ago)
      expect(user.reviews).to eq([rev2, rev1, rev3])
    end
  end

  describe "::queue_items" do
    let(:user) { Fabricate(:user) }
    let(:video1) { Fabricate(:video) }
    let(:video2) { Fabricate(:video) }
    let(:video3) { Fabricate(:video) }
    it "returns an empty array if no queue items" do
      expect(user.queue_items).to eq([])
    end 
    context "wiht multiple items" do 
      before do

      end
      it "returns an array with multiple items if queue has many items" do
        q1 = QueueItem.create(user: user, video: video1, position: 3)
        q2 = QueueItem.create(user: user, video: video2, position: 1)
        q3 = QueueItem.create(user: user, video: video3, position: 2)
        expect(user.queue_items).to match_array([q1, q2, q3])
      end
      it "returns the queue items, ordered by their position" do 
        q1 = QueueItem.create(user: user, video: video1, position: 3)
        q2 = QueueItem.create(user: user, video: video2, position: 1)
        q3 = QueueItem.create(user: user, video: video3, position: 2)
        expect(user.queue_items).to eq([q2, q3, q1])
      end
      it "returns the que items, ordered reverse chronologicaly, if two items of the same have the same position" do 
        q1 = QueueItem.create(user: user, video: video1, position: 2, created_at: 2.days.ago)
        q2 = QueueItem.create(user: user, video: video2, position: 2, created_at: 1.day.ago)
        expect(user.queue_items).to eq([q2, q1])
      end
    end
  end

  describe "#queued_video?" do
    let(:user) { Fabricate(:user) }
    let(:video) { Fabricate(:video) }
    it "is true if the user has the video in their queue" do
      Fabricate(:queue_item, user: user, video: video)
      expect(user.queued_video?(video)).to be true
    end
    it "is false if the user does not have the video in their queue" do
      Fabricate(:queue_item, video: video)
      expect(user.queued_video?(video)).to be false
    end
  end

  describe "#followed_users" do
    it "returns the accounts followed by the user" do
      follow_me = Fabricate(:user)
      user = Fabricate(:user)
      Fabricate(:relationship, user: user, followed_user: follow_me)
      expect(user.followed_users).to match_array [follow_me]
    end
  end
  
  describe "#followers" do
    it "returns the accounts that follow the user" do
      follow_me = Fabricate(:user)
      user = Fabricate(:user)
      Fabricate(:relationship, user: user, followed_user: follow_me)
      expect(follow_me.followers).to match_array [user]
    end
  end

  describe "#follows?" do
    let(:user) { Fabricate(:user) }
    let(:followed_user) { Fabricate(:user) }
    it 'is true if the user follows the user passed in the argument' do
      Fabricate(:relationship, user: user, followed_user: followed_user)
      expect(user.follows?(followed_user)).to be_true
    end
    it 'is false if the user does not follow the user passed in the argument' do
      expect(user.follows?(followed_user)).to be_false
    end
  end

  describe "#can_follow?" do
    let(:user) { Fabricate(:user) }
    let(:followed_user) { Fabricate(:user) }
    it 'is true if the user can follow the user in the argument' do
      expect(user.can_follow?(followed_user)).to be_true
    end
    it 'is false if the user in the argument is the user itself' do
      expect(user.can_follow?(user)).to be_false
    end
    it 'is false if the use already follows the user in the argument' do
      Fabricate(:relationship, user: user, followed_user: followed_user)
      expect(user.can_follow?(followed_user)).to be_false
    end
  end
end