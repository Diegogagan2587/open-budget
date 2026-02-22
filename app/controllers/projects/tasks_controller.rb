module Projects
  class TasksController < ApplicationController
    before_action :set_project
    before_action :set_task, only: [:show, :edit, :update, :destroy]
    before_action :ensure_task_access, only: [:show, :edit, :update, :destroy]

    def index
      @tasks = @project.tasks.order(created_at: :desc)
    end

    def show
    end

    def new
      @task = @project.tasks.build
    end

    def create
      @task = @project.tasks.build(task_params)
      @task.user = Current.user
      @task.account = Current.account

      if @task.save
        redirect_to projects_project_task_path(@project, @task), notice: t("tasks.flash.created")
      else
        Rails.logger.error("Task validation errors: #{@task.errors.full_messages}")
        render :new
      end
    end

    def edit
    end

    def update
      if @task.update(task_params)
        redirect_to projects_project_task_path(@project, @task), notice: t("tasks.flash.updated")
      else
        render :edit
      end
    end

    def destroy
      @task.destroy
      redirect_to projects_project_tasks_url(@project), notice: t("tasks.flash.destroyed")
    end

    private

    def set_project
      @project = Project.for_account(Current.account).find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to projects_url
    end

    def set_task
      @task = @project.tasks.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to project_tasks_url(@project)
    end

    def ensure_task_access
      unless @task && @task.account_id == Current.account.id
        redirect_to project_tasks_url(@project)
      end
    end

    def task_params
      params.require(:task).permit(:title, :description, :status, :priority, :due_date)
    end
  end
end
