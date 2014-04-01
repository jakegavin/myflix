require 'spec_helper'

describe ReviewsController do
  describe "POST #create" do
    let (:video) { Fabricate(:video) }
    it_behaves_like "requires authenticated user" do
      let(:action) { post :create, video_id: video.id }
    end

    context "with authenticated user" do
      before { set_current_user }
      let(:user) { current_user }
    
      it "sets the @video variable" do
        post :create, video_id: video.id, review: Fabricate.attributes_for(:review, video: nil, user: nil)
        expect(assigns(:video)).to eq(video)
      end
      it "sets the @review variable" do 
        post :create, video_id: video.id, review: Fabricate.attributes_for(:review, video: nil, user: nil)
        expect(assigns(:review)).to be_instance_of(Review)
      end
      context "with valid attributes" do 
        before { post :create, video_id: video.id, review: Fabricate.attributes_for(:review, video: nil, user: nil) }
        it "saves the review" do 
          expect(video.reviews.count).to eq(1)
        end
        it "shows a success notice" do
          expect(flash[:success]).to_not be_empty
        end
        it "creates a review associated with the current user" do
          expect(video.reviews.first.user).to eq(user)
        end
        it "creates a review associated with the video" do
          expect(Review.first.video).to eq(video)
        end
        it "redirects to the video path" do
          expect(response).to redirect_to video_path(video)
        end
      end

      context "with invalid attributes" do
        before { post :create, video_id: video.id, review: Fabricate.attributes_for(:review, video: video, text: nil, user: nil) }
        it "does not save the review" do 
          expect(video.reviews.count).to eq(0)
        end
        it "renders videos#show" do
          expect(response).to render_template('videos/show')
        end
      end
    end
  end
end