require 'spec_helper'

describe ResetPasswordsController do
  describe "GET #show" do
    context "authenticated user" do
      it 'redirects to the home path' do
        set_current_user
        get :show, id: 1234
        expect(response).to redirect_to home_path
      end
    end  
    context "with unauthenticated user" do
      it 'renders the show template if the token is valid' do
        alice = Fabricate(:user, password_reset_token: SecureRandom.urlsafe_base64)
        get :show, id: alice.password_reset_token
        expect(response).to render_template :show
      end
      it 'redirects to invalid token page if token is invalid' do
        Fabricate(:user)
        get :show, id: SecureRandom.urlsafe_base64
        expect(response).to redirect_to invalid_token_path
      end
      it 'sets @user' do
        alice = Fabricate(:user, password_reset_token: SecureRandom.urlsafe_base64)
        get :show, id: alice.password_reset_token
        expect(assigns(:user)).to eq(alice)
      end
    end
  end

  describe "POST #create" do
    context "authenticated user" do
      it 'redirects to the home path' do
        set_current_user
        post :create
        expect(response).to redirect_to home_path
      end
    end
    context "with unauthenticated user" do
      let!(:alice) { Fabricate(:user, password_reset_token: SecureRandom.urlsafe_base64) }
      context 'with invalid token' do
        it 'redirects to invalid token page' do
          post :create, password_reset_token: 1234, password: 'password'
          expect(response).to redirect_to invalid_token_path
        end
      end
      context 'with valid token' do
        context 'with valid password attributes' do
          let!(:password) { Faker::Internet.password }
          before { post :create, password_reset_token: alice.password_reset_token, password: password }
          it 'changes the users password' do
            expect(User.first.authenticate(password)).to be_true
          end
          it 'sets the password_reset_token to nil' do
            expect(User.first.password_reset_token).to be_nil
          end
          it 'redirects to the sign in path' do
            expect(response).to redirect_to login_path
          end
          it 'sets the success flash message' do
            expect(flash[:success]).to_not be_nil
          end
          it 'sets @user' do
            expect(assigns(:user)).to eq(alice)
          end
        end
      end
    end
  end
end