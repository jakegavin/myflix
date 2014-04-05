require 'spec_helper'

describe UsersController do
  describe "GET #new" do
    context "with authenticated user" do
      before { set_current_user }
      it "redirects to home path" do
        get :new
        expect(response).to redirect_to home_path
      end
    end
    context "with unathenticated user" do
      it "assigns a new User to @user" do 
        get :new
        expect(assigns(:user)).to be_new_record
        expect(assigns(:user)).to be_instance_of(User)
      end
    end
  end
  describe "POST #create" do
    context "with authenticated user" do
      before { set_current_user }
      it "redirects to home path" do
        post :create
        expect(response).to redirect_to home_path
      end
    end
    context "with unathenticated user" do
      context "with valid attributes" do
        before { post :create, user: Fabricate.attributes_for(:user) }
        it "saves the new user" do
          expect(User.count).to eq(1)
        end
        it "redirects to the home path" do
          expect(response).to redirect_to home_path
        end
        it "logs the user in" do
          expect(session[:user_id]).to be_true
        end
      end
      context "with invald attributes" do
        before { post :create, user: Fabricate.attributes_for(:user, name: nil) }
        it "sets the @user variable" do
          expect(assigns(:user)).to be_new_record
          expect(assigns(:user)).to be_instance_of(User)
        end
        it "does not save the new user" do 
          expect(User.count).to eq(0)
        end
        it "re-renders the :new template" do
          expect(response).to render_template(:new)
        end
      end
    end
  end
  describe "GET #show" do
   it_behaves_like "requires authenticated user" do

    end

    context 'with authenticated user' do

    end
  end
end