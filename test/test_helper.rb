ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Helper for integration tests to set up authentication
module ActionDispatch
  class IntegrationTest
    def sign_in_as(user, account = nil)
      account ||= user.accounts.first
      post session_path, params: {
        email_address: user.email_address,
        password: "password"
      }

      if account.present? && account != user.accounts.first
        post account_switch_path, params: { account_id: account.id }
      end

      Current.account = account
      Current.session
    end
  end
end
