module Career
  module JobApplications
    class UpdateStatusService
      Result = Struct.new(:success?, :job_application, :errors)

      def self.call(job_application:, actor:, params:)
        new(job_application:, actor:, params:).call
      end

      def initialize(job_application:, actor:, params:)
        @job_application = job_application
        @actor = actor
        @params = params
      end

      def call
        old_status = job_application.status

        unless job_application.update(filtered_params)
          return Result.new(false, job_application, job_application.errors.full_messages)
        end

        if old_status != job_application.status
          job_application.update_column(:applied_on, Date.current) if job_application.status == "applied" && job_application.applied_on.blank?

          Career::Event.create!(
            account: job_application.account,
            job_application: job_application,
            event_type: status_event_type(job_application.status),
            occurred_at: Time.current,
            metadata: {
              from: old_status,
              to: job_application.status,
              updated_by_id: actor&.id
            }.compact
          )
        end

        Result.new(true, job_application, [])
      rescue ActiveRecord::RecordInvalid => e
        Result.new(false, job_application, [e.message])
      end

      private

      attr_reader :job_application, :actor, :params

      def filtered_params
        params.except(:company_name)
      end

      def status_event_type(status)
        case status
        when "applied" then "applied"
        when "rejected" then "rejected"
        when "offer" then "offer_received"
        when "withdrawn" then "withdrawn"
        when "ghosted" then "ghosted"
        else "status_changed"
        end
      end
    end
  end
end
