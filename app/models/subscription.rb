# The Subscription model represents a subscription record.
# It stores information about subscriptions created through Stripe.
#
# @!attribute stripe_subscription_id
#   @return [String] The unique identifier for the subscription from Stripe.
#
# @!attribute status
#   @return [String] The current status of the subscription.
#   Can be 'unpaid', 'paid', or 'canceled'.
class Subscription < ApplicationRecord
  # Validations
  validates :stripe_subscription_id, presence: true

  # Enums
  # Defines the possible statuses of a subscription.
  enum status: { unpaid: 'unpaid', paid: 'paid', canceled: 'canceled' }
end
