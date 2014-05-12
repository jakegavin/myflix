describe InvitesController do
  describe 'GET #new' do
    it_behaves_like 'requires authenticated user' do
      let(:action) { get :new }
    end
    it 'assigns a new Invite instance to @invite with authenticated user' do
      set_current_user
      get :new
      expect(assigns(:invite)).to be_new_record
      expect(assigns(:invite)).to be_instance_of(Invite)
    end
  end

  describe 'POST #create' do
    it_behaves_like 'requires authenticated user' do
      let(:action) { post :create, invite: Fabricate.attributes_for(:invite) }
    end
    context 'with authenticated user' do
      before { set_current_user }
      context 'with invalid attributes' do
        before { post :create, invite: Fabricate.attributes_for(:invite, name: nil) }
        it "doesn't create a new invite" do
          expect(Invite.all.size).to eq(0)
        end
        it 'sets the @invite variable' do
          expect(assigns(:invite)).to be_new_record
          expect(assigns(:invite)).to be_instance_of(Invite)
        end
        it 're-renders the new template' do
          expect(response).to render_template(:new)
        end
      end
      context 'with valid attributes' do
        before { post :create, invite: Fabricate.attributes_for(:invite) }
        it 'creates a new invite' do
          expect(Invite.all.size).to eq(1)
        end
        it 'creates an invite associated with the current user' do
          expect(Invite.last.inviter).to eq(current_user)
        end
        it 'redirects to the home path' do
          expect(response).to redirect_to home_path
        end
        it 'sets a flash success message' do
          expect(flash[:success]).to_not be_nil
        end
      end
      context 'send email' do
        before { post :create, invite: Fabricate.attributes_for(:invite, email: 'test@email.com') }
        after { ActionMailer::Base.deliveries.clear }
        it 'sends an email to the invited person' do
          email = ActionMailer::Base.deliveries.last
          expect(email.to).to eq(['test@email.com'])
        end
        it 'sends an email with the name of the user who sent the invite' do
          email = ActionMailer::Base.deliveries.last
          expect(email.body).to include(current_user.name)
        end
      end
    end
  end
end