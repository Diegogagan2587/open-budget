module Projects
  class ProjectsController < ApplicationController
    before_action :set_project, only: [ :show, :edit, :update, :destroy ]
    before_action :ensure_project_access, only: [ :show, :edit, :update, :destroy ]
    before_action :ensure_project_owner, only: [ :edit, :update, :destroy ]

    def index
      @projects = Project.for_account(Current.account).order(created_at: :desc)
    end

    def show
      @tasks = @project.tasks.order(created_at: :desc)
      @docs = @project.docs
      @links = @project.links
      @meetings = @project.meetings.upcoming
    end

    def new
      @project = Project.for_account(Current.account).build
    end

    def create
      @project = Project.for_account(Current.account).build(project_params)
      @project.user = Current.user
      @project.account = Current.account

      if @project.save
        redirect_to @project, notice: t("projects.flash.created")
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @project.update(project_params)
        redirect_to @project, notice: t("projects.flash.updated")
      else
        render :edit
      end
    end

    def destroy
      @project.destroy
      redirect_to projects_url, notice: t("projects.flash.destroyed")
    end

    private

    def set_project
      @project = Project.for_account(Current.account).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to projects_url
    end

    def ensure_project_access
      unless @project && @project.account_id == Current.account.id
        redirect_to projects_url
      end
    end

    def ensure_project_owner
      unless @project.owner_id == Current.user.id
        redirect_to @project
      end
    end

    def project_params
      params.require(:project).permit(:name, :summary, :status, :priority, :start_date, :end_date)
    end
  end
end
