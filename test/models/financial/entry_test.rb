require "test_helper"

class Financial::EntryTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!(name: "Tenant Account")
    Current.account = @account
    @financial_account = Financial::Asset.create!(
      account: @account,
      name: "Main Debit",
      account_type: "debit",
      status: "active",
      opening_balance: 0
    )
  end

  def teardown
    Current.account = nil
  end

  test "transfer requires destination account" do
    entry = Financial::Entry.new(
      account: @account,
      financial_account: @financial_account,
      entry_type: "transfer",
      entry_date: Date.current,
      amount: 10,
      description: "Move"
    )

    assert_not entry.valid?
    assert_includes entry.errors[:counterparty_financial_account], "must be selected"
  end

  test "liability payment requires liability and account" do
    entry = Financial::Entry.new(
      account: @account,
      entry_type: "liability_payment",
      entry_date: Date.current,
      amount: 20,
      description: "Card payment"
    )

    assert_not entry.valid?
    assert_includes entry.errors[:financial_account], "must be selected"
    assert_includes entry.errors[:financial_liability], "must be selected"
  end

  test "loan disbursement requires origin and one destination" do
    entry = Financial::Entry.new(
      account: @account,
      entry_type: "loan_disbursement",
      entry_date: Date.current,
      amount: 50,
      description: "Loan move"
    )

    assert_not entry.valid?
    assert_includes entry.errors[:financial_liability], "must be selected"
    assert_includes entry.errors[:base], "loan disbursement requires an asset or liability destination"
  end
end
