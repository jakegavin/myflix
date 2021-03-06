require 'spec_helper'

describe Admin::VideosController do
  describe 'GET #new' do
    it_behaves_like 'requires admin' do
      let(:action) { get :new }
    end
    it 'assigns the @video variable' do
      set_current_user(Fabricate(:admin))
      get :new
      expect(assigns(:video)).to be_instance_of(Video)
      expect(assigns(:video)).to be_new_record
    end
  end

  describe 'POST #create' do
    it_behaves_like 'requires admin' do
      let(:action) { post :create, video: Fabricate.attributes_for(:video) }
    end
    context 'with admin' do
      before { set_current_user(Fabricate(:admin)) }
      context 'general tests' do
        before { post :create, video: Fabricate.attributes_for(:video) }
        it 'sets the @video variable' do
          expect(assigns(:video)).to be_instance_of(Video)
        end
      end
      context 'with valid attributes' do
        before { post :create, video: Fabricate.attributes_for(:video) }
        it 'creates the video' do
          expect(Video.all.size).to eq(1)
        end
        it 'sets a flash success message' do
          expect(flash[:success]).to_not be_nil
        end
        it 'redirects to the home path' do
          expect(response).to redirect_to home_path
        end
      end
      context 'with invalid attributes' do
        before { post :create, video: Fabricate.attributes_for(:video, title: nil) }
        it 'does not create a video' do
          expect(Video.all.size).to eq(0)
        end
        it 're-renders the new template' do
          expect(response).to render_template :new
        end
      end
    end
  end
end