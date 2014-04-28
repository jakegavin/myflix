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
      context 'with valid invite token' do
        it 'assigns the invite variable' do
          invite = Fabricate(:invite)
          get :new, invite_token: invite.invite_token
          expect(assigns(:invite)).to eq(Invite.find_by(invite_token: invite.invite_token))
        end
      end
      context 'with invalid invite_token' do
        it 'does not assign the invite variable' do
          invite = Fabricate(:invite)
          get :new, invite_token: SecureRandom.urlsafe_base64
          expect(assigns(:invite)).to be_nil
        end
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
        after { ActionMailer::Base.deliveries.clear }
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
      context 'with valid invite token' do
        it 'assigns the invite variable' do
          invite = Fabricate(:invite)
          post :create, user: Fabricate.attributes_for(:user), invite_token: invite.invite_token
          expect(assigns(:invite)).to eq(Invite.find_by(invite_token: invite.invite_token))
        end
        it 'creates a relationship where the new user follows the inviter' do
          inviter = Fabricate(:user)
          invite = Fabricate(:invite, inviter: inviter)
          post :create, user: Fabricate.attributes_for(:user), invite_token: invite.invite_token
          expect(User.last.followed_users).to eq([inviter])
        end
        it 'creates a relationship where the inviter follows the new user' do
          inviter = Fabricate(:user)
          invite = Fabricate(:invite, inviter: inviter)
          post :create, user: Fabricate.attributes_for(:user), invite_token: invite.invite_token
          expect(User.first.followed_users).to eq([User.last])
        end
        it 'deletes all invites associated with the new users email' do
          new_email = Faker::Internet.email
          3.times { Fabricate(:invite, email: new_email) }
          Fabricate(:invite)
          post :create, user: Fabricate.attributes_for(:user, email: new_email, invite_token: Invite.first.invite_token)
          expect(Invite.all.size).to eq(1)
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
end