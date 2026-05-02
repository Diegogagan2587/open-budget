module Loans
  class DisbursementSyncService
    Result = Struct.new(:success?, :error_message, :entry, keyword_init: true)

    def self.call(loan)
      new(loan).call
    end

    def initialize(loan)
      @loan = loan
    end

    def call
      return failure("Loan event is required") if loan.blank?
      return failure("Loan liability is required") if loan.loan_liability.blank?

      entry = Financial::Entry.for_account(loan.account).find_or_initialize_by(
        income_event: loan,
        entry_type: "loan_disbursement"
      )
      entry.account ||= loan.account
      entry.assign_attributes(entry_attributes)
      entry.save!

      Result.new(success?: true, entry: entry)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.to_sentence)
    end

    private

    attr_reader :loan

    def entry_attributes
      attrs = {
        financial_liability: loan.loan_liability,
        entry_date: loan.received_date || loan.expected_date,
        amount: (loan.loan_amount || loan.expected_amount),
        description: "Loan disbursement for #{loan.description}"
      }

      if loan.loan_disbursement_destination_asset.present?
        attrs[:financial_account] = loan.loan_disbursement_destination_asset
        attrs[:counterparty_financial_liability] = nil
      else
        attrs[:financial_account] = nil
        attrs[:counterparty_financial_liability] = loan.loan_disbursement_destination_liability
      end

      attrs
    end

    def failure(message)
      Result.new(success?: false, error_message: message)
    end
  end
end
