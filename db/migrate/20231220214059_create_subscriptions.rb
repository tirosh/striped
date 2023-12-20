class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_subscription_id
      t.string :status

      t.timestamps
    end
  end
end
