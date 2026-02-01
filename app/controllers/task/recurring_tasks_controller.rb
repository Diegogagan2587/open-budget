# frozen_string_literal: true

module Task
  class RecurringTasksController < ApplicationController
    before_action :set_recurring_task, only: [ :show, :edit, :update, :destroy, :mark_done ]
    before_action :set_task_areas, only: [ :index, :new, :create, :edit, :update ]

    def index
      @recurring_tasks = RecurringTask.for_account(Current.account).pending.by_next_due
      @recurring_tasks = @recurring_tasks.where(task_area_id: params[:task_area_id]) if params[:task_area_id].present?
    end

    def show
    end

    def new
      @recurring_task = RecurringTask.new(next_due_date: Date.current)
    end

    def create
      @recurring_task = RecurringTask.for_account(Current.account).new(recurring_task_params)
      @recurring_task.account = Current.account

      if @recurring_task.save
        redirect_to task_recurring_tasks_path, notice: t("task.recurring_tasks.flash.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @recurring_task.update(recurring_task_params)
        redirect_to task_recurring_tasks_path, notice: t("task.recurring_tasks.flash.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @recurring_task.destroy!
      redirect_to task_recurring_tasks_path, status: :see_other, notice: t("task.recurring_tasks.flash.destroyed")
    end

    def mark_done
      @recurring_task.mark_done!
      redirect_to task_recurring_tasks_path, notice: t("task.recurring_tasks.flash.mark_done")
    end

    private

    def set_recurring_task
      @recurring_task = RecurringTask.for_account(Current.account).find(params[:id])
    end

    def set_task_areas
      @task_areas = TaskArea.for_account(Current.account).order(:name)
    end

    def recurring_task_params
      params.require(:recurring_task).permit(:name, :task_area_id, :recurrence, :next_due_date, :notes)
    end
  end
end
