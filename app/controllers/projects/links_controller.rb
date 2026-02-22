module Projects
  class LinksController < ApplicationController
    before_action :set_project
    before_action :set_link, only: [:show, :edit, :update, :destroy]
    before_action :ensure_link_access, only: [:show, :edit, :update, :destroy]

    def index
      @links = @project.links.order(created_at: :desc)
    end

    def show
    end

    def new
      @link = Link.new
    end

    def create
      @link = Link.new(link_params)
      @link.account = Current.account

      if @link.save
        @project.links << @link unless @project.links.include?(@link)
        redirect_to projects_project_link_path(@project, @link), notice: t("links.flash.created")
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @link.update(link_params)
        respond_to do |format|
          format.html { redirect_to projects_project_link_path(@project, @link), notice: t("links.flash.updated") }
          format.json { render json: { id: @link.id }, status: :ok }
        end
      else
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: { errors: @link.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @link.destroy
      redirect_to projects_project_links_path(@project), notice: t("links.flash.destroyed")
    end

    private

    def set_project
      @project = Project.for_account(Current.account).find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to projects_url
    end

    def set_link
      @link = @project.links.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to projects_project_links_path(@project)
    end

    def ensure_link_access
      unless @link && @link.account_id == Current.account.id
        redirect_to projects_project_links_path(@project)
      end
    end

    def link_params
      params.require(:link).permit(:title, :url, :description, :link_type)
    end
  end
end
