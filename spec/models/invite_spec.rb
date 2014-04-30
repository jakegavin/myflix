require 'spec_helper'

describe Invite do
  it { should belong_to(:inviter) }
  it { should validate_presence_of(:inviter) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:message) }

  it 'should generate a token when created' do
    new_invite = Fabricate(:invite)
    expect(new_invite.reload.token).to_not be_nil
  end

  it_behaves_like 'tokenable' do
    let(:object) { Fabricate(:invite) }
  end
end
