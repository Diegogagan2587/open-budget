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
      session = user.sessions.create!(
        user_agent: "Test Agent",
        ip_address: "127.0.0.1"
      )
      # Set Current values that will be used by authentication
      Current.session = session
      Current.account = account
      # Also try to set cookie if possible
      if respond_to?(:cookies) && cookies.respond_to?(:[]=)
        # For integration tests, we'll rely on Current.session being set
        # The authentication concern checks Current.session first
      end
      session
    end
  end
end
