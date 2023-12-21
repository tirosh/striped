# README

## Striped
A Rails Application for Stripe Event Handling

### Description
Striped is a Ruby on Rails application designed to integrate with Stripe for subscription management. It processes webhook events from Stripe to create and update subscription records in the local database based on the lifecycle of each subscription.

**Expected Behavior:**
- creating a subscription on [stripe.com](https://dashboard.stripe.com/test/subscriptions) (via subscription UI) creates a simple subscription record in your database
- the initial state of the subscription record should be `unpaid`
- paying the first invoice of the subscription changes the state of your local subscription record from `unpaid` to `paid`
- canceling a subscription changes the state of your subscription record to `canceled`
- only subscriptions in the state `paid` can be canceled

### Requirements
- Ruby 3.1.4
- Rails 7.1.2
- PostgreSQL
- Stripe account for API keys

### Installation

1. **Clone the Repository**
   ```
   git clone https://github.com/tirosh/striped.git
   cd striped
   ```

2. **Install Dependencies**
   - Install Ruby and Bundler dependencies:
     ```
     bundle install
     ```
   - Install JavaScript dependencies:
     ```
     yarn install
     ```

3. **Database Setup**
   - Create and migrate the database:
     ```
     rails db:create
     rails db:migrate
     ```

4. **Stripe Configuration**
   - Sign up for a Stripe account and get your API keys.
   - Set up your Stripe API keys in `config/credentials.yml.enc`:
     ```
     EDITOR="code --wait" rails credentials:edit
     ```
     Add your Stripe keys:
     ```yaml
     stripe:
       secret_key: sk_test_...
       publishable_key: pk_test_...
       webhook_secret: whsec_...
     ```

### Running the Application

- Start the Rails server:
  ```
  rails s
  ```

- Access the application at `http://localhost:3000`.

### Running Tests

- Execute the test suite:
  ```
  rails test
  ```

### Additional Information

- To test webhook events locally, use tools like [ngrok](https://ngrok.com/) to expose your local server.
- For webhook setup and testing, follow the instructions provided in the [Stripe documentation](https://stripe.com/docs).

#### Stripe
- [Register](https://dashboard.stripe.com/register) a free Stripe account
- [Subscription UI](https://dashboard.stripe.com/subscriptions) to create a subscription and pay the invoice
