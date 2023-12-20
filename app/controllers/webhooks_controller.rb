class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:stripe]

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    # Verify webhook signature and extract the event
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials.stripe[:webhook_secret]
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      render json: { message: e.message }, status: 400
      return
    end

    # Handle the event
    case event['type']
    when 'customer.subscription.created'
      handle_subscription_created(event['data']['object'])
    end

    render json: { message: 'Success' }
  end

  private

  def handle_subscription_created(subscription)
    # Create a new Subscription record in your database
    # Set the initial state as 'unpaid'
    Subscription.create(
      stripe_subscription_id: subscription['id'],
      status: 'unpaid'
    )
  end
end
