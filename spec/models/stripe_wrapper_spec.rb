require 'spec_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge, :vcr do
    describe '.create' do
      before { StripeWrapper.set_api_key }
      let(:token) { Stripe::Token.create(card: {number: card_number, exp_month: 12, exp_year: 2020, cvc: '123'}).id }
      let(:wrapper) { StripeWrapper::Charge.create(amount: 300, card: token) }
      context 'with valid card' do
        let(:card_number) { '4242424242424242' }
        it 'should successfully charge the card' do
          expect(wrapper).to be_successful
          expect(wrapper.response.amount).to eq(300)
          expect(wrapper.response.currency).to eq('usd')
        end
      end
      context 'with invalid card' do
        let(:card_number) { '4000000000000002' }
        it 'should not successfully charge the card' do
          expect(wrapper).to_not be_successful

        end
        it 'should return an error message' do
          expect(wrapper.error_message).to eq 'Your card was declined.'
        end
      end
    end
  end
end