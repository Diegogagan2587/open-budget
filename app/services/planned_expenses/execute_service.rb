module PlannedExpenses
  class ExecuteService
    Result = Struct.new(:success?, :error_message, :planned_expense, :expense, :entry, keyword_init: true)

    def self.call(...)
      new(...).call
    end

    def initialize(planned_expense:, entry_date: Date.current)
      @planned_expense = planned_expense
      @entry_date = entry_date
    end

    def call
      return failure("Planned expense is required") if planned_expense.blank?

      ActiveRecord::Base.transaction do
        if transaction_routing?
          expense = nil
          entry = create_financial_entry!
        else
          expense = planned_expense.expense || Expense.new
          expense.assign_attributes(expense_attributes)
          expense.save!
          entry = nil
        end

        planned_expense.update!(status: status_after_execution) unless planned_expense.status == status_after_execution

        Result.new(success?: true, planned_expense: planned_expense, expense: expense, entry: entry)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.to_sentence)
    end

    private

    attr_reader :planned_expense, :entry_date

    def expense_attributes
      {
        date: entry_date,
        amount: planned_expense.amount,
        description: planned_expense.description,
        category: planned_expense.category,
        budget_period: planned_expense.income_event.budget_period,
        income_event: planned_expense.income_event,
        planned_expense: planned_expense,
        account: planned_expense.account,
        financial_account: planned_expense.financial_account,
        financial_liability: planned_expense.financial_liability
      }
    end

    def create_financial_entry!
      entry = Financial::Entry.new(
        account: planned_expense.account,
        income_event: planned_expense.income_event,
        planned_expense: planned_expense,
        entry_date: entry_date,
        amount: planned_expense.amount,
        description: planned_expense.description
      )

      if planned_expense.transfer?
        entry.entry_type = "transfer"
        entry.financial_account = planned_expense.financial_account
        entry.counterparty_financial_account = planned_expense.counterparty_financial_account
        entry.financial_liability = nil
      elsif planned_expense.debt_payment?
        entry.entry_type = "liability_payment"
        entry.financial_account = planned_expense.financial_account
        entry.financial_liability = planned_expense.financial_liability
        entry.counterparty_financial_account = nil
      else
        raise ActiveRecord::RecordInvalid.new(entry)
      end

      entry.save!
      entry
    end

    def transaction_routing?
      planned_expense.transfer? || planned_expense.debt_payment?
    end

    def status_after_execution
      return "transferred" if planned_expense.transfer?
      return "paid" if planned_expense.debt_payment?

      "paid"
    end

    def failure(message)
      Result.new(success?: false, error_message: message, planned_expense: planned_expense)
    end
  end
end