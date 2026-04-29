module Expenses
  class RecordExecutionService
    Result = Struct.new(:success?, :error_message, :expense, :entry, keyword_init: true)

    def self.call(...)
      new(...).call
    end

    def initialize(expense:, financial_account_id: nil, financial_liability_id: nil)
      @expense = expense
      @financial_account_id = financial_account_id
      @financial_liability_id = financial_liability_id
    end

    def call
      return failure("Expense is required") if expense.blank?

      ActiveRecord::Base.transaction do
        expense.financial_account = asset_account if asset_account.present?
        expense.financial_liability = liability if liability.present?
        expense.save!

        created_entry = build_entry
        return Result.new(success?: true, expense: expense, entry: created_entry)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.to_sentence)
    end

    private

    attr_reader :expense, :financial_account_id, :financial_liability_id

    def asset_account
      @asset_account ||= Financial::Asset.for_account(expense.account).find_by(id: financial_account_id)
    end

    def liability
      @liability ||= Financial::Liability.for_account(expense.account).find_by(id: financial_liability_id)
    end

    def build_entry
      if liability.present?
        Financial::Entry.create!(
          account: expense.account,
          financial_liability: liability,
          expense: expense,
          income_event: expense.income_event,
          entry_type: "liability_charge",
          entry_date: expense.date,
          amount: expense.amount,
          description: expense.description
        )
      elsif asset_account.present?
        Financial::Entry.create!(
          account: expense.account,
          financial_account: asset_account,
          expense: expense,
          income_event: expense.income_event,
          entry_type: "outflow",
          entry_date: expense.date,
          amount: expense.amount,
          description: expense.description
        )
      end
    end

    def failure(message)
      Result.new(success?: false, error_message: message)
    end
  end
end
