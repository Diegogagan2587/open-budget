module Projects
  class LinksController < ApplicationController
    before_action :set_project, if: -> { params[:project_id].present? }
    before_action :set_link, only: [ :show, :edit, :update, :destroy ]
    before_action :ensure_link_access, only: [ :show, :edit, :update, :destroy ]

    def index
      @links = if @project
        @project.links.order(created_at: :desc)
      else
        Link.for_account(Current.account).order(created_at: :desc)
      end
    end

    def show
    end

    def new
      @link = Link.new
      @return_to_doc_id = params[:return_to_doc_id]
      @return_to_project_id = params[:return_to_project_id]
    end

    def create
      # Extract return_to parameters before creating the link
      return_to_doc_id = params[:link]&.delete(:return_to_doc_id)
      return_to_project_id = params[:link]&.delete(:return_to_project_id)

      @link = Link.new(link_params)
      @link.account = Current.account

      if @link.save
        # Associate with project if provided
        if @project
          @project.links << @link unless @project.links.include?(@link)
        end

        # Associate with doc if return params provided
        if return_to_doc_id.present?
          doc = Doc.for_account(Current.account).find(return_to_doc_id)
          doc.links << @link unless doc.links.include?(@link)
          redirect_to projects_project_doc_path(return_to_project_id, doc), notice: t("links.flash.created")
        elsif @project
          redirect_to projects_project_link_path(@project, @link), notice: t("links.flash.created")
        else
          redirect_to projects_link_path(@link), notice: t("links.flash.created")
        end
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @link.update(link_params)
        respond_to do |format|
          if @project
            format.html { redirect_to projects_project_link_path(@project, @link), notice: t("links.flash.updated") }
          else
            format.html { redirect_to projects_link_path(@link), notice: t("links.flash.updated") }
          end
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
      if @project
        redirect_to projects_project_links_path(@project), notice: t("links.flash.destroyed")
      else
        redirect_to projects_links_path, notice: t("links.flash.destroyed")
      end
    end

    private

    def set_project
      @project = Project.for_account(Current.account).find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to projects_projects_path
    end

    def set_link
      if @project
        @link = @project.links.find(params[:id])
      else
        @link = Link.for_account(Current.account).find(params[:id])
      end
    rescue ActiveRecord::RecordNotFound
      if @project
        redirect_to projects_project_links_path(@project)
      else
        redirect_to projects_links_path
      end
    end

    def ensure_link_access
      unless @link && @link.account_id == Current.account.id
        if @project
          redirect_to projects_project_links_path(@project)
        else
          redirect_to projects_links_path
        end
      end
    end

    def link_params
      params.require(:link).permit(:title, :url, :description, :link_type)
    end
  end
end
