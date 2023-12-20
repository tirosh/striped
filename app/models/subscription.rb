class Subscription < ApplicationRecord
  validates :stripe_subscription_id, presence: true

  enum status: { unpaid: 'unpaid', paid: 'paid', canceled: 'canceled' }
end
