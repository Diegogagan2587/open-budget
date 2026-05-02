require "test_helper"

class IncomeEventsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @account = accounts(:one)
    Current.account = @account

    @loan_liability = Financial::Liability.create!(
      account: @account,
      name: "Loan Origin",
      liability_type: "personal_credit",
      status: "active",
      opening_balance: 0
    )

    @destination_asset = Financial::Asset.create!(
      account: @account,
      name: "Checking",
      account_type: "checking",
      status: "active",
      opening_balance: 0
    )

    Category.create!(name: "Debt", account: @account)

    @loan_income_event = IncomeEvent.create!(
      account: @account,
      description: "Loan Income",
      expected_date: Date.current,
      expected_amount: 1000,
      income_type: "loan",
      loan_amount: 1000,
      number_of_payments: 2,
      payment_frequency: "monthly",
      payment_amount: 550,
      status: "pending",
      loan_liability: @loan_liability,
      destination_selection: "asset:#{@destination_asset.id}"
    )
  end

  def teardown
    Current.account = nil
    Current.session = nil
  end

  def sign_in
    post session_path, params: {
      email_address: @user.email_address,
      password: "password"
    }
    Current.account = @account
  end

  test "mark as received creates loan disbursement entry" do
    sign_in

    assert_difference("Financial::Entry.where(entry_type: 'loan_disbursement', income_event_id: #{@loan_income_event.id}).count", 1) do
      patch receive_income_event_path(@loan_income_event), params: {
        income_event: {
          received_date: Date.current,
          received_amount: 1000
        }
      }
    end

    assert_redirected_to income_event_path(@loan_income_event)

    entry = Financial::Entry.where(entry_type: "loan_disbursement", income_event_id: @loan_income_event.id).first
    assert_not_nil entry
    assert_equal @loan_liability.id, entry.financial_liability_id
    assert_equal @destination_asset.id, entry.financial_account_id
    assert_equal 1000.to_d, entry.amount.to_d
  end
end
