require "test_helper"

class Projects::TaskTest < ActiveSupport::TestCase
  def setup
    @account = accounts(:one)
    Current.account = @account
    @user = users(:one)

    # Create test projects
    @project_one = Projects::Project.create!(
      account: @account,
      user: @user,
      name: "Project One",
      status: "active",
      priority: "medium"
    )

    @project_two = Projects::Project.create!(
      account: @account,
      user: @user,
      name: "Project Two",
      status: "active",
      priority: "medium"
    )

    # Create test tasks with various priorities and due dates
    @task_overdue = Projects::Task.create!(
      account: @account,
      project: @project_one,
      user: @user,
      title: "High Priority Overdue Task",
      description: "This task is high priority and overdue",
      status: "in_progress",
      priority: "high",
      due_date: 5.days.ago.to_date
    )

    @task_high_soon = Projects::Task.create!(
      account: @account,
      project: @project_one,
      user: @user,
      title: "High Priority Due Soon",
      description: "This task is high priority due soon",
      status: "backlog",
      priority: "high",
      due_date: 2.days.from_now.to_date
    )

    @task_medium_later = Projects::Task.create!(
      account: @account,
      project: @project_two,
      user: @user,
      title: "Medium Priority Due Later",
      description: "This task is medium priority due later",
      status: "blocked",
      priority: "medium",
      due_date: 10.days.from_now.to_date
    )

    @task_low_no_date = Projects::Task.create!(
      account: @account,
      project: @project_one,
      user: @user,
      title: "Low Priority No Date",
      description: "This task is low priority with no due date",
      status: "in_review",
      priority: "low",
      due_date: nil
    )

    @task_completed = Projects::Task.create!(
      account: @account,
      project: @project_two,
      user: @user,
      title: "Completed Task",
      description: "This task is completed",
      status: "done",
      priority: "high",
      due_date: 1.day.ago.to_date,
      completed_at: 1.hour.ago
    )
  end

  def teardown
    Current.account = nil
  end

  # Test by_urgency scope - overdue first, then high priority, then soonest due
  test "by_urgency returns overdue tasks first" do
    tasks = Projects::Task.by_urgency.pending
    assert_equal @task_overdue.id, tasks.first.id
  end

  test "by_urgency orders by priority after overdue" do
    # Get pending tasks sorted by urgency
    tasks = Projects::Task.by_urgency.pending.to_a

    # Find positions of high priority tasks
    high_priority_tasks = tasks.select { |t| t.priority == "high" }
    medium_priority_tasks = tasks.select { |t| t.priority == "medium" }

    # High priority should come before medium priority
    if high_priority_tasks.any? && medium_priority_tasks.any?
      high_position = tasks.index(high_priority_tasks.first)
      medium_position = tasks.index(medium_priority_tasks.first)
      assert high_position < medium_position
    end
  end

  test "by_urgency orders by due date for same priority" do
    # Create two high priority non-overdue tasks with different due dates
    soon_task = Projects::Task.create!(
      account: @account,
      user: @user,
      title: "High Priority Soon",
      status: "backlog",
      priority: "high",
      due_date: 1.day.from_now.to_date
    )

    later_task = Projects::Task.create!(
      account: @account,
      user: @user,
      title: "High Priority Later",
      status: "backlog",
      priority: "high",
      due_date: 30.days.from_now.to_date
    )

    tasks = Projects::Task.by_urgency.where(id: [ soon_task.id, later_task.id ])
    assert_equal soon_task.id, tasks.first.id
    assert_equal later_task.id, tasks.second.id
  end

  test "by_priority_desc returns high priority first" do
    tasks = Projects::Task.by_priority_desc.pending
    # First pending task should be high priority
    assert_equal "high", tasks.first.priority
  end

  test "by_priority_desc orders high > medium > low" do
    tasks = Projects::Task.by_priority_desc.pending.to_a

    # Get unique priorities in order
    unique_priorities = tasks.map(&:priority).uniq

    if unique_priorities.include?("high") && unique_priorities.include?("medium")
      high_idx = tasks.index { |t| t.priority == "high" }
      medium_idx = tasks.index { |t| t.priority == "medium" }
      assert high_idx < medium_idx
    end
  end

  test "by_due_date_asc returns overdue first" do
    tasks = Projects::Task.by_due_date_asc.pending
    assert_equal @task_overdue.id, tasks.first.id
  end

  test "by_due_date_asc orders by soonest due date" do
    tasks = Projects::Task.by_due_date_asc.pending.to_a
    # After overdue, should be ordered by due_date ASC (soonest first)
    due_dates = tasks.filter { |t| !t.overdue? }.map(&:due_date).compact
    assert_equal due_dates, due_dates.sort
  end

  test "newest_first orders by created_at desc" do
    tasks = Projects::Task.newest_first
    created_ats = tasks.map(&:created_at)
    assert_equal created_ats, created_ats.sort.reverse
  end

  test "overdue? returns true for past due_date" do
    assert @task_overdue.overdue?
  end

  test "overdue? returns false for future due_date" do
    assert_not @task_high_soon.overdue?
  end

  test "overdue? returns false for nil due_date" do
    assert_not @task_low_no_date.overdue?
  end

  test "completed tasks are excluded from pending scopes" do
    pending_tasks = Projects::Task.pending
    completed_task_ids = Projects::Task.completed.map(&:id)

    pending_tasks.each do |task|
      assert_not_includes completed_task_ids, task.id
    end
  end

  test "by_urgency with completed tasks excludes pending statuses" do
    tasks = Projects::Task.by_urgency.completed
    assert_not_includes tasks.map(&:status), "in_progress"
    assert_not_includes tasks.map(&:status), "backlog"
  end

  test "pending scope includes only active statuses" do
    pending_tasks = Projects::Task.pending
    pending_tasks.each do |task|
      assert_includes %w[blocked backlog in_progress in_review], task.status
    end
  end

  test "completed scope includes only completed statuses" do
    completed_tasks = Projects::Task.completed
    completed_tasks.each do |task|
      assert_includes %w[done cancelled], task.status
    end
  end
end
