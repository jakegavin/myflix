require 'spec_helper'

describe QueueItemsController do
  describe "GET #index" do
    context "with unauthenticated user" do
      it "redirects to root_path" do
        get :index
        expect(response).to redirect_to root_path
      end
    end
    context "with authenticated user" do
      let(:user) { Fabricate(:user) }
      let(:q1) { Fabricate(:queue_item, user: user) }
      let(:q2) { Fabricate(:queue_item, user: user) }
      before { session[:user_id] = user.id }
      it "assigns the @queue_items variable" do
        get :index
        expect(assigns(:queue_items)).to match_array([q1, q2])
      end 
    end
  end

  describe 'POST #create' do
    context "with unauthenticated user" do
      it "redirects to the root_path" do
        post :create, video_id: 1 
        expect(response).to redirect_to root_path
      end
    end
    context "with authenticated user" do
      let(:user) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      before do 
        session[:user_id] = user.id
      end
      it "redirects to the queue_path" do
        post :create, video_id: video.id
        expect(response).to redirect_to queue_path
      end
      it "creates a queue item associated with current user" do
        post :create, video_id: video.id
        expect(QueueItem.last.user_id).to eq(user.id) 
      end
      it "creates a queue item associated with the video" do
        post :create, video_id: video.id
        expect(QueueItem.last.video).to eq(Video.find(video.id))
      end
      it "puts the new item at the end of the users queue" do
        Fabricate(:queue_item, user: user, position: 1)
        Fabricate(:queue_item, user: user, position: 2)
        Fabricate(:queue_item, user: user, position: 3)
        Fabricate(:queue_item, user: user, position: 4)
        post :create, video_id: video.id
        expect(QueueItem.last.position).to eq(5)
      end
      it "saves the queue_item if video isn't already in queue" do
        post :create, video_id: video.id
        expect(QueueItem.all.count).to eq(1)
      end
      it "doesn't add the item if its already in the queue" do
        Fabricate(:queue_item, video: video, user: user, position: 1)
        post :create, video_id: video.id
        expect(QueueItem.all.count).to eq(1)        
      end
    end
  end

  describe 'DELETE #destroy' do
    context "with unauthenticated user" do
      it "redirects to the root_path" do
        qi = Fabricate(:queue_item)
        delete :destroy, id: qi.id
        expect(response).to redirect_to root_path
      end
    end
    context "with authenticated user" do
      let(:user) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      before do 
        session[:user_id] = user.id
      end
      it "deletes the queue item" do
        qi = Fabricate(:queue_item, user: user)
        delete :destroy, id: qi.id
        expect(QueueItem.all.count).to eq(0)
      end
      it "does not delete items that the current user does not own" do
        user2 = Fabricate(:user)
        q1 = Fabricate(:queue_item, user: user2)
        delete :destroy, id: q1.id
        expect(QueueItem.all.count).to eq(1)
      end
      it "decreases the position of following queue items by one if there are other items" do
        q1 = Fabricate(:queue_item, user: user, position: 1)
        q2 = Fabricate(:queue_item, user: user, position: 2)
        q3 = Fabricate(:queue_item, user: user, position: 3)
        q4 = Fabricate(:queue_item, user: user, position: 4)
        delete :destroy, id: q2.id
        expect(user.queue_items[-2].position).to eq(2)
        expect(user.queue_items[-1].position).to eq(3)
      end
      it "redirects to the queue path" do
        qi = Fabricate(:queue_item, user: user)
        delete :destroy, id: qi.id
        expect(response).to redirect_to queue_path
      end
    end
  end
end