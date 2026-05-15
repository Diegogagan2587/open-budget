module Career
  module JobApplications
    class CreateService
      Result = Struct.new(:success?, :job_application, :errors)

      def self.call(account:, user:, params:)
        new(account:, user:, params:).call
      end

      def initialize(account:, user:, params:)
        @account = account
        @user = user
        @params = params
      end

      def call
        job_application = nil

        ActiveRecord::Base.transaction do
          company = find_or_create_company!
          if company.nil?
            temp_job_application = Career::JobApplication.new
            temp_job_application.errors.add(:base, "Company name is required")
            return Result.new(false, temp_job_application, temp_job_application.errors.full_messages)
          end

          job_application = Career::JobApplication.new(job_application_attributes)
          job_application.account = account
          job_application.company = company
          job_application.found_on ||= Date.current

          unless job_application.save
            return Result.new(false, job_application, job_application.errors.full_messages)
          end

          Career::Event.create!(
            account: account,
            job_application: job_application,
            event_type: "found",
            occurred_at: Time.current,
            metadata: {
              source: job_application.source,
              created_by_id: user&.id
            }.compact
          )
        end

        Result.new(true, job_application, [])
      rescue ActiveRecord::RecordInvalid => e
        Result.new(false, job_application, [ e.message ])
      end

      private

      attr_reader :account, :user, :params

      def find_or_create_company!
        if params[:career_company_id].present?
          company = Career::Company.for_account(account).find_by(id: params[:career_company_id])
          return company if company.present?
        end

        name = params[:company_name].to_s.strip
        return nil if name.blank?

        Career::Company.for_account(account).where("LOWER(name) = ?", name.downcase).first_or_create!(name: name)
      end

      def job_application_attributes
        params.except(:company_name, :career_company_id)
      end
    end
  end
end
