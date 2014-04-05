require 'spec_helper'

describe VideosController do
  describe "GET #show" do 
    let (:video) { Fabricate(:video) }  
    it "sets the @video variable for authenticated users" do
      set_current_user
      get :show, id: video
      expect(assigns(:video)).to eq video
    end
    it "sets the @review variable for authenticated users" do 
      set_current_user
      get :show, id: video
      expect(assigns(:review)).to be_new_record
      expect(assigns(:review)).to be_instance_of(Review)
    end
    it_behaves_like "requires authenticated user" do
      let(:action) { get :show, id: video }
    end
  end

  describe "GET #search" do
    let (:video) { Fabricate(:video) }  
    it "sets the @videos variable for authenticated users" do 
      set_current_user
      get :search, search_term: video.title
      expect(assigns(:videos)).to include(video)
    end
    it_behaves_like "requires authenticated user" do
      let(:action) { get :search, search_term: video.title }
    end
  end
end