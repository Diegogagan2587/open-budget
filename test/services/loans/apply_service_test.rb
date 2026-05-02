require "test_helper"

class Loans::ApplyServiceTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!(name: "Loan Household")
    Current.account = @account

    @origin_liability = Financial::Liability.create!(account: @account, name: "New Loan", liability_type: "personal_credit", status: "active", opening_balance: 0)
    @destination_asset = Financial::Asset.create!(account: @account, name: "Checking", account_type: "checking", status: "active", opening_balance: 100)
    Category.create!(name: "Debt", account: @account)

    @loan = IncomeEvent.create!(
      account: @account,
      description: "Personal Loan",
      expected_date: Date.current,
      expected_amount: 1000,
      income_type: "loan",
      loan_amount: 1000,
      number_of_payments: 3,
      payment_frequency: "monthly",
      payment_amount: 350,
      status: "received",
      loan_liability: @origin_liability,
      destination_selection: "asset:#{@destination_asset.id}"
    )
  end

  def teardown
    Current.account = nil
  end

  test "apply creates or updates a single disbursement entry" do
    assert_difference("Financial::Entry.where(entry_type: 'loan_disbursement').count", 1) do
      result = Loans::ApplyService.call(@loan)
      assert result.success?
    end

    assert_no_difference("Financial::Entry.where(entry_type: 'loan_disbursement').count") do
      result = Loans::ApplyService.call(@loan)
      assert result.success?
    end

    entry = @loan.reload.loan_disbursement_entry
    assert_not_nil entry
    assert_equal @origin_liability.id, entry.financial_liability_id
    assert_equal @destination_asset.id, entry.financial_account_id
    assert_equal "applied", @loan.status
  end

  test "updating applied loan reconciles disbursement entry" do
    Loans::ApplyService.call(@loan)

    @loan.update!(loan_amount: 1250, expected_amount: 1250, payment_amount: 450)

    entry = @loan.reload.loan_disbursement_entry
    assert_equal 1250.to_d, entry.amount.to_d
  end

  test "syncs planned expenses by installment number without duplication" do
    assert_no_difference("@loan.planned_expenses.count") do
      Loans::PlannedExpenseSyncService.call(@loan)
    end

    assert_no_difference("@loan.planned_expenses.count") do
      Loans::PlannedExpenseSyncService.call(@loan)
    end

    first = @loan.planned_expenses.find_by!(loan_installment_number: 1)
    first.update!(status: "paid")

    @loan.update!(payment_amount: 400)
    first.reload
    assert_equal "paid", first.status
  end
end
