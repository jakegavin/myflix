require 'spec_helper'

describe ForgotPasswordsController do
  describe "GET #new" do
    context "authenticated user" do
      it 'redirects to the home path' do
        set_current_user
        get :new
        expect(response).to redirect_to home_path
      end
    end
  end
  describe "POST #create" do
    context "authenticated user" do
      it 'redirects to the home path' do
        set_current_user
        post :create, email: Faker::Internet.email
        expect(response).to redirect_to home_path
      end
    end
     context "with unauthenticated user" do
      context "with invalid email address" do
        before { post :create, email: Faker::Internet.email }
        it "renders the new template" do
          expect(response).to render_template :new
        end
        it "sets a flash message saying invalid email" do
          expect(flash[:danger]).to_not be_nil
        end
      end
      context "with blank email address" do
        let!(:alice) { Fabricate(:user) }
        before { post :create, email: nil }
        it "renders the new template" do
          expect(response).to render_template :new
        end
        it "sets a flash message saying invalid email" do
          expect(flash[:danger]).to_not be_nil
        end
        it "does not set a password reset token" do
          expect(User.first.password_reset_token).to be_nil
        end
      end
      context "with valid email address" do
        let!(:alice) { Fabricate(:user) }
        before { post :create, email: alice.email }
        after { ActionMailer::Base.deliveries.clear }
        it "it sets the password_reset_token column for the associated user" do
          expect(User.last.password_reset_token).to_not be_nil
        end
        it "sends an email with a link to the reset password page" do
          expect(ActionMailer::Base.deliveries.last.to).to eq([alice.email])
          expect(ActionMailer::Base.deliveries.last.body).to include(User.last.password_reset_token)
        end
        it "redirects to password reset confirmation" do
          expect(response).to redirect_to password_reset_confirmation_path
        end
      end
    end
  end


   



end