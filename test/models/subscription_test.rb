require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  test 'should not save subscription without stripe_subscription_id' do
    subscription = Subscription.new(status: 'unpaid')
    assert_not subscription.save, 'Saved the subscription without a stripe_subscription_id'
  end

  test 'should save valid subscription' do
    subscription = Subscription.new(stripe_subscription_id: 'sub_123', status: 'unpaid')
    assert subscription.save, "Couldn't save the valid subscription"
  end

  test 'should handle status enum correctly' do
    subscription = Subscription.create(stripe_subscription_id: 'sub_123', status: 'unpaid')
    assert subscription.unpaid?, 'Subscription status should be unpaid'
    subscription.paid!
    assert subscription.paid?, 'Subscription status should be paid'
  end
end
