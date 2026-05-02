module Loans
  class ApplyService
    Result = Struct.new(:success?, :error_message, :entry, keyword_init: true)

    def self.call(loan)
      new(loan).call
    end

    def initialize(loan)
      @loan = loan
    end

    def call
      return failure("Loan event is required") if loan.blank?

      ActiveRecord::Base.transaction do
        disbursement = Loans::DisbursementSyncService.call(loan)
        return failure(disbursement.error_message) unless disbursement.success?

        loan.update!(status: "applied") unless loan.status == "applied"
        Result.new(success?: true, entry: disbursement.entry)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.to_sentence)
    end

    private

    attr_reader :loan

    def failure(message)
      Result.new(success?: false, error_message: message)
    end
  end
end
