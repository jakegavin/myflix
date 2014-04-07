require 'spec_helper'

describe RelationshipsController do
  describe 'GET #index' do
    it_behaves_like 'requires authenticated user' do
      let(:action) { get :index }
    end
    context 'with authenticated user' do
      it 'sets the @relationships variable to an array of current users relationships' do
        current_user = Fabricate(:user)
        set_current_user(current_user)
        user1 = Fabricate(:user)
        user2 = Fabricate(:user)
        r1 = Fabricate(:relationship, user: current_user, followed_user: user1)
        r2 = Fabricate(:relationship, user: current_user, followed_user: user2)
        get :index
        expect(assigns(:relationships)).to match_array [r1, r2]
      end
    end
  end

  describe 'POST #create' do
    it_behaves_like 'requires authenticated user' do
      let(:action) { post :create, followed_id: 1 }
    end
    context 'with authenticated user' do
      let(:followed_user) { Fabricate(:user) }
      before { set_current_user }
      it 'creates a relationship' do
        post :create, followed_id: followed_user.id
        expect(Relationship.all.size).to eq(1)
      end
      it 'sets the user id to the current users id' do
        post :create, followed_id: followed_user.id
        expect(Relationship.first.user).to eq(current_user)
      end
      it 'sets the followed id to the followed id provided in the params' do
        post :create, followed_id: followed_user.id
        expect(Relationship.first.followed_user).to eq(followed_user)
      end
      it 'redirects to the people I follow page' do
        post :create, followed_id: followed_user.id
        expect(response).to redirect_to following_path
      end
      it 'does not allow the someone to follow the same user twice' do
        Fabricate(:relationship, user: current_user, followed_user: followed_user)
        post :create, followed_id: followed_user.id
        expect(Relationship.all.size).to eq(1)
      end
      it 'does not allow users to follow themselves' do
        post :create, followed_id: current_user.id
        expect(Relationship.all.size).to eq(0)
      end
    end
  end

  describe 'DELETE #destroy' do
    it_behaves_like 'requires authenticated user' do
      let(:relationship) { Fabricate(:relationship) }
      let(:action) { delete :destroy, id: relationship.id }
    end
    context 'with authenticated user' do
      let(:followed_user) { Fabricate(:user) }
      before { set_current_user }
      it 'destroys the relationship with the id provided in the params' do
        relationship = Fabricate(:relationship, user: current_user, followed_user: followed_user)
        delete :destroy, id: relationship.id
        expect(Relationship.all.size).to eq(0)
      end
      it 'does not delete relationships that the current user does not own' do
        other_realtionship = Fabricate(:relationship, followed_user: followed_user)
        delete :destroy, id: other_realtionship.id
        expect(Relationship.all.size).to eq(1)
      end
      it 'redirects to the people I follow page' do
        relationship = Fabricate(:relationship, user: current_user, followed_user: followed_user)
        delete :destroy, id: relationship.id
        expect(response).to redirect_to following_path
      end
    end
  end
end

