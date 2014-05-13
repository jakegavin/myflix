require 'spec_helper'

describe UserCreation do
  describe '#create_and_charge_user' do
    after { ActionMailer::Base.deliveries.clear }
    context 'with valid attributes and valid payment' do
      before do
        charge = double('charge', id: 1)
        allow(charge).to receive(:successful?).and_return(true)
        allow(StripeWrapper::Charge).to receive(:create).and_return(charge)
      end
      it 'saves the user' do
        UserCreation.new(Fabricate.build(:user)).create_and_charge_user
        expect(User.all.size).to eq 1
      end
      it 'charges the user' do
        charge = double('charge', id: 1)
        allow(charge).to receive(:successful?).and_return(true)
        expect(StripeWrapper::Charge).to receive(:create).and_return(charge)
        UserCreation.new(Fabricate.build(:user)).create_and_charge_user
      end
      it 'sets the status to success' do
        creation = UserCreation.new(Fabricate.build(:user))
        creation.create_and_charge_user
        expect(creation.status).to eq(:success)
      end

    end
    context 'with valid attributes and invalid payment' do
      before do
        charge = double('charge')
        allow(charge).to receive(:successful?).and_return(false)
        allow(charge).to receive(:error_message).and_return('Your card was declined.')
        allow(StripeWrapper::Charge).to receive(:create).and_return(charge)
      end
      it 'does not save the user' do
        UserCreation.new(Fabricate.build(:user)).create_and_charge_user
        expect(User.all.size).to eq(0)
      end
      it 'sets the message to failed payment' do
        creation = UserCreation.new(Fabricate.build(:user))
        creation.create_and_charge_user
        expect(creation.message).to eq('Your card was declined.')
      end
      it 'sets the status to failed' do
        creation = UserCreation.new(Fabricate.build(:user))
        creation.create_and_charge_user
        expect(creation.status).to eq(:fail)
      end
    end
    context 'with invalid attributes' do
      before do
        charge = double('charge')
        allow(charge).to receive(:successful?).and_return(true)
        expect(StripeWrapper::Charge).to_not receive(:create)
      end
      it 'does not charge the user' do
        UserCreation.new(Fabricate.build(:user, name: nil)).create_and_charge_user
      end
      it 'does not save the user' do
        UserCreation.new(Fabricate.build(:user, name: nil)).create_and_charge_user
        expect(User.all.size).to eq(0)
      end
      it 'sets the status to failed' do
        creation = UserCreation.new(Fabricate.build(:user, name: nil))
        creation.create_and_charge_user
        expect(creation.status).to eq :fail
      end
    end
  end  
end
