# WebhooksController handles incoming webhook requests from Stripe.
# It processes various Stripe events and updates local subscription records accordingly.
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:stripe]

  # Entry point for Stripe webhook events.
  #
  # @note Skips CSRF token verification as it's an external source.
  #
  # @return [JSON] Returns a success message if the event is processed correctly.
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
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event['data']['object'])
    when 'invoice.payment_succeeded'
      handle_payment_succeeded(event['data']['object'])
    end

    render json: { message: 'Success' }
  end

  private

  # Handles the 'customer.subscription.created' event.
  # It creates a new subscription record in the database with the status 'unpaid'.
  #
  # @param subscription [Hash] The subscription object from Stripe event data.
  def handle_subscription_created(subscription)
    # Create a new Subscription record in your database
    # Set the initial state as 'unpaid'
    Subscription.create(
      stripe_subscription_id: subscription['id'],
      status: 'unpaid'
    )
  end

  # Handles the 'customer.subscription.deleted' event.
  # It updates the subscription record's status to 'canceled' if its current status is 'paid'.
  #
  # @param subscription [Stripe::Subscription] The subscription object from Stripe event data.
  def handle_subscription_deleted(subscription)
    # Find the subscription in your database
    local_subscription = Subscription.find_by(stripe_subscription_id: subscription.id)

    # Update the status to 'canceled' if it's currently 'paid'
    local_subscription.update(status: 'canceled') if local_subscription&.paid?
  end

  # Handles the 'invoice.payment_succeeded' event.
  # It updates the subscription record's status to 'paid' if its current status is 'unpaid'.
  #
  # @param invoice [Stripe::Invoice] The invoice object from Stripe event data.
  def handle_payment_succeeded(invoice)
    # Find the subscription associated with the invoice
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)

    # Update the subscription status to 'paid' if it's currently 'unpaid'
    subscription.update(status: 'paid') if subscription&.unpaid?
  end
end
