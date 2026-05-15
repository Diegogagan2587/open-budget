module Career
  class DashboardController < ApplicationController
    def index
      @today_actions = Projects::Task.for_account(Current.account)
        .where(taskable_type: "Career::JobApplication")
        .pending
        .order(
          Arel.sql("CASE WHEN due_date IS NULL THEN 1 ELSE 0 END"),
          due_date: :asc,
          created_at: :desc
        )
        .limit(10)

      @pipeline_summary = Career::JobApplication.for_account(Current.account).group(:status).count
      @recent_applications = Career::JobApplication.for_account(Current.account).includes(:company).recent_first.limit(8)
    end
  end
end
