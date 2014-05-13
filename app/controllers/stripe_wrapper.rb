module StripeWrapper
  class Charge
    attr_reader :response, :status, :id

    def initialize(response, status, id)
      @response = response
      @status = status
      @id = id
    end

    def self.create(options={})
      StripeWrapper.set_api_key
      begin
        response = Stripe::Customer.create(card: options[:card], plan: "basic", email: options[:email])
        new(response, :success, response.id)
      rescue Stripe::CardError => e
        new(e, :error, nil)
      end
    end

    def successful?
      status == :success
    end

    def error_message
      response.message
    end
  end

  def self.set_api_key
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  end
end
