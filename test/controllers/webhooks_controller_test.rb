require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test 'should create subscription on customer.subscription.created' do
    assert_difference 'Subscription.count', 1 do
      post webhooks_stripe_url, params: stripe_event('customer.subscription.created', 'sub_mock_id'),
                                as: :json
    end
    assert_response :success
  end

  test 'should update subscription on invoice.payment_succeeded' do
    subscription = Subscription.create(stripe_subscription_id: 'sub_123', status: 'unpaid')
    post webhooks_stripe_url, params: stripe_event('invoice.payment_succeeded', subscription.stripe_subscription_id),
                              as: :json
    assert_response :success
    assert_equal 'paid', subscription.reload.status
  end

  test 'should update subscription on customer.subscription.deleted' do
    subscription = Subscription.create(stripe_subscription_id: 'sub_123', status: 'paid')
    post webhooks_stripe_url, params: stripe_event('customer.subscription.deleted', subscription.stripe_subscription_id),
                              as: :json
    assert_response :success
    assert_equal 'canceled', subscription.reload.status
  end

  private

  def stripe_event(type, id)
    case type
    when 'customer.subscription.created', 'customer.subscription.deleted'
      {
        type:, # Type of event
        data: {
          object: {
            id: # Subscription ID
          }
        }
      }
    when 'invoice.payment_succeeded'
      {
        type:, # Type of event
        data: {
          object: {
            subscription: id # Subscription ID
          }
        }
      }
    end
  end
end
