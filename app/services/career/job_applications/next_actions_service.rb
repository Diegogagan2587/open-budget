module Career
  module JobApplications
    class NextActionsService
      def self.call(job_application:)
        new(job_application:).call
      end

      def initialize(job_application:)
        @job_application = job_application
      end

      def call
        existing_keys = job_application.tasks.pending
          .where("metadata ->> 'source' = ?", "career_template")
          .pluck(Arel.sql("metadata ->> 'template_key'"))
          .compact

        Career::TaskTemplates.for_status(job_application.status)
          .reject { |template| existing_keys.include?(template.key) }
      end

      private

      attr_reader :job_application
    end
  end
end
