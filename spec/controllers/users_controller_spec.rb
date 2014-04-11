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
      context "email sending" do
        after { ActionMailer::Base.deliveries.clear }
        context 'with valid attributes' do
          before { post :create, user: Fabricate.attributes_for(:user) }
          it 'sends an email' do
            expect(ActionMailer::Base.deliveries).to_not be_empty
          end
          it 'sends the email to the correct address' do
            email = ActionMailer::Base.deliveries.last
            expect(email.to).to eq([User.last.email])
          end
          it 'sends the email with the right content' do
            email = ActionMailer::Base.deliveries.last
            expect(email.body).to include("Hi #{User.last.name}")
            expect(email.body).to include("You successfully registered for Myflix.")
          end
        end
        context 'with invalid attributes' do
          before { post :create, user: Fabricate.attributes_for(:user, name: nil) }
          it 'does not send an email' do
            expect(ActionMailer::Base.deliveries).to be_empty
          end
        end
      end
    end
  end
  describe "GET #show" do
   it_behaves_like "requires authenticated user" do
      let(:action) { get :show, id: 1 }
    end

    context 'with authenticated user' do
      let(:shown_user) { Fabricate(:user) }
      before do
        3.times do
          Fabricate(:review, user: shown_user)
          Fabricate(:queue_item, user: shown_user)
        end
        set_current_user
        get :show, id: shown_user.id
      end
      it 'assigns the @variable to the correct user' do
        expect(assigns(:user)).to eq(shown_user)
      end
      it 'assigns an array of the users reviews to @reviews' do
        expect(assigns(:reviews)).to match_array shown_user.reviews
      end
      it 'assigns an array of the users queue items to @queue_items' do
        expect(assigns(:queue_items)).to match_array shown_user.queue_items
      end
    end
  end
  describe "GET #forgot_password" do
    context "authenticated user" do
      it 'redirects to the home path' do
        set_current_user
        get :forgot_password
        expect(response).to redirect_to home_path
      end
    end
  end

  describe "POST #generate_token" do
    context "authenticated user" do
      it 'redirects to the home path' do
        set_current_user
        post :generate_token, email: Faker::Internet.email
        expect(response).to redirect_to home_path
      end
    end
    context "with unauthenticated user" do
      context "with invalid email address" do
        before { post :generate_token, email: Faker::Internet.email }
        it "renders the forgot_password page" do
          expect(response).to render_template :forgot_password
        end
        it "sets a flash message saying invalid email" do
          expect(flash[:danger]).to_not be_nil
        end
      end
      context "with valid email address" do
        let!(:alice) { Fabricate(:user) }
        before { post :generate_token, email: alice.email }
        after { ActionMailer::Base.deliveries.clear }
        it "it sets the password_reset_token column for the associated user" do
          expect(User.last.password_reset_token).to_not be_nil
        end
        it "sends an email with a link to the reset password page" do
          expect(ActionMailer::Base.deliveries.last.body).to include(User.last.password_reset_token)
        end
        it "redirects to password reset confirmation" do
          expect(response).to redirect_to password_reset_confirmation_path
        end
      end
    end
  end

  describe "GET #reset_password" do
    context "authenticated user" do
      it 'redirects to the home path' do
        set_current_user
        get :reset_password
        expect(response).to redirect_to home_path
      end
    end
    context "with unauthenticated user" do
      it 'renders the reset_password template if the token is valid' do
        alice = Fabricate(:user, password_reset_token: SecureRandom.urlsafe_base64)
        get :reset_password, password_reset_token: alice.password_reset_token
        expect(response).to render_template :reset_password
      end
      it 'redirects to invalid token page if token is invalid' do
        Fabricate(:user)
        get :reset_password, password_reset_token: SecureRandom.urlsafe_base64
        expect(response).to redirect_to invalid_token_path
      end
      it 'redirects to invalid token page if token is nil' do
        Fabricate(:user)
        get :reset_password, password_reset_token: nil
        expect(response).to redirect_to invalid_token_path
      end
    end
  end

  describe "POST #reset_password" do {}
    context "authenticated user" do
      it 'redirects to the home path' do
        set_current_user
        get :reset_password
        expect(response).to redirect_to home_path
      end
    end
    context "with unauthenticated user" do
      let!(:alice) { Fabricate(:user, password_reset_token: SecureRandom.urlsafe_base64) }
      context 'with valid password attributes' do
        let!(:password) { Faker::Internet.password }
        before { post :reset_password, password_reset_token: alice.password_reset_token, password: password }
        it 'changes the users password' do
          expect(User.first.authenticate(password)).to be_true
        end
        it 'sets the password_reset_token to nil' do
          expect(User.first.password_reset_token).to be_nil
        end
        it 'redirects to the sign in path' do
          expect(response).to redirect_to login_path
        end
      end
      context 'with invalid password attributes' do
        let!(:password) { "a" }
        before { post :reset_password, password_reset_token: alice.password_reset_token, password: password }
        it 're-renders the password reset template' do
          # Its not catching these because password only validates on create
          expect(response).to render_template :reset_password
        end
      end
    end

  end

end