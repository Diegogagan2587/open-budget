class DashboardController < ApplicationController
  def index
    @due_soon_tasks = RecurringTask.for_account(Current.account).pending.by_next_due.limit(5) if Current.account
  end
end
