require 'spec_helper'

describe QueueItemsController do
  describe "GET #index" do
    it_behaves_like "requires authenticated user" do
      let(:action) { get :index }
    end
    context "with authenticated user" do
      let(:q1) { Fabricate(:queue_item, user: user) }
      let(:q2) { Fabricate(:queue_item, user: user) }
      before { set_current_user }
      let(:user) { current_user }
      it "assigns the @queue_items variable" do
        get :index
        expect(assigns(:queue_items)).to match_array([q1, q2])
      end 
    end
  end

  describe 'POST #create' do
    it_behaves_like "requires authenticated user" do
      let(:action) { post :create, video_id: 1 }
    end
    context "with authenticated user" do
      let(:video) { Fabricate(:video) }
      before { set_current_user }
      let(:user) { current_user }
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
    it_behaves_like "requires authenticated user" do
      let(:action) do
        qi = Fabricate(:queue_item)
        delete :destroy, id: qi.id
      end
    end
    context "with authenticated user" do
      let(:video) { Fabricate(:video) }
      before { set_current_user }
      let(:user) { current_user }
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

  describe 'POST #modify' do 
    it_behaves_like "requires authenticated user" do
      let(:action) { post :modify }
    end  
    context 'with authenticated user' do
      before { set_current_user }
      let (:user) { current_user }
      it 'redirects to the queue path' do
         q1 = Fabricate(:queue_item, user: user, position: 1)
        post :modify, queue_items: [{id:1, position: 1}]
        expect(response).to redirect_to queue_path
      end
      context 'with invalid parameters for position' do
        it "doesn't update the queue items order" do
          q1 = Fabricate(:queue_item, user: user, position: 1)
          q2 = Fabricate(:queue_item, user: user, position: 2)
          q3 = Fabricate(:queue_item, user: user, position: 3)
          post :modify, queue_items: [{id: 1, position: 2.5}, {id: 2, position: 1}, {id: 3, position: 3}]
          expect(user.queue_items).to eq([q1, q2, q3])
        end
        it "doesn't change the queue items' position" do 
          q1 = Fabricate(:queue_item, user: user, position: 1)
          q2 = Fabricate(:queue_item, user: user, position: 2)
          q3 = Fabricate(:queue_item, user: user, position: 3)
          post :modify, queue_items: [{id: 1, position: 2.5}, {id: 2, position: 1}, {id: 3, position: 3}]
          expect(q1.reload.position).to eq(1)
          expect(q2.reload.position).to eq(2)
          expect(q3.reload.position).to eq(3)
        end
        it "sets the flash danger alert" do
          q1 = Fabricate(:queue_item, user: user, position: 1)
          q2 = Fabricate(:queue_item, user: user, position: 2)
          q3 = Fabricate(:queue_item, user: user, position: 3)
          post :modify, queue_items: [{id: 1, position: 2.5}, {id: 2, position: 1}, {id: 3, position: 3}]
          expect(flash[:danger]).to_not be_nil
        end
      end
      context 'with valid parameters for position' do 
        it "updates the queue items' order if first item is moved into second place" do
          q1 = Fabricate(:queue_item, user: user, position: 1)
          q2 = Fabricate(:queue_item, user: user, position: 2)
          q3 = Fabricate(:queue_item, user: user, position: 3)
          post :modify, queue_items: [{id: 1, position: 2}, {id: 2, position: 1}, {id: 3, position: 3}]
          expect(user.queue_items).to eq([q2, q1, q3])
        end
        it "updates the queue items positions so they start with 1" do
          q1 = Fabricate(:queue_item, user: user, position: 1)
          q2 = Fabricate(:queue_item, user: user, position: 2)
          q3 = Fabricate(:queue_item, user: user, position: 3)
          post :modify, queue_items: [{id: 1, position: 4}, {id: 2, position: 2}, {id: 3, position: 3}]
          expect(q1.reload.position).to eq(3)
          expect(q2.reload.position).to eq(1)
          expect(q3.reload.position).to eq(2)
        end
      end
      context 'user does not own the queue_item' do 
        it "does not change the queue items' position" do
          q1 = Fabricate(:queue_item, position: 1)
          q2 = Fabricate(:queue_item, position: 2)
          post :modify, queue_items: [{id: 1, position: 2}, {id: 2, position: 1}]
          expect(q1.reload.position).to eq(1)
          expect(q2.reload.position).to eq(2)          
        end
      end
      context 'altering the rating' do
        let (:video) { Fabricate(:video) }
        it "creates a new review if the user hasn't already reviewed the video" do
          q1 = Fabricate(:queue_item, user: user, position: 1)
          post :modify, queue_items: [{id: 1, user: user, video: video, position: 1, rating: 3}]
          expect(Review.all.count).to eq(1)
        end
        it "doesn't create a new review if a review already exists" do
          q1 = Fabricate(:queue_item, user: user, video: video, position: 1)
          rev = Fabricate(:review, video: video, user: user, rating: 3)
          post :modify, queue_items: [{id: 1, user: user, video: video, position: 1, rating: 5}]
          expect(QueueItem.all.size).to eq(1)
        end
        it "changes the rating in the review if it already exists" do
          q1 = Fabricate(:queue_item, user: user, video: video, position: 1)
          rev = Fabricate(:review, video: video, user: user, rating: 3)
          post :modify, queue_items: [{id: 1, user: user, video: video, position: 1, rating: 5}]
          expect(rev.reload.rating).to eq(5)
        end
        it "clears the rating if an empty rating is submitted and the review (with text) already exists" do
          q1 = Fabricate(:queue_item, user: user, video: video, position: 1)
          rev = Fabricate(:review, video: video, user: user, rating: 3)
          post :modify, queue_items: [{id: 1, user: user, video: video, position: 1, rating: ""}]
          expect(rev.reload.rating).to be_nil
        end
        it "deletes the review if an empty rating is submitted and the existing review has nil text" do
          q1 = Fabricate(:queue_item, user: user, video: video, position: 1)
          rev = Fabricate(:review, video: video, user: user, rating: 3)
          rev.update_column(:text, nil)
          post :modify, queue_items: [{id: 1, user: user, video: video, position: 1, rating: ""}]
          expect(Review.all.size).to eq(0)
        end
      end
    end
  end
end