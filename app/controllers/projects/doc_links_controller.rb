module Projects
  class DocLinksController < ApplicationController
    before_action :set_doc
    before_action :set_link, only: [ :destroy ]

    def create
      @link = Projects::Link.for_account(Current.account).find(params[:link_id])

      if @doc.links << @link
        redirect_to doc_path, notice: t("projects.flash.link_added")
      else
        redirect_to doc_path, alert: t("projects.flash.link_add_failed")
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to doc_path, alert: t("projects.flash.link_already_added")
    end

    def destroy
      @doc.links.delete(@link)
      redirect_to doc_path, notice: t("projects.flash.link_removed")
    end

    private

    def set_doc
      @doc = Projects::Doc.for_account(Current.account).find(params[:doc_id])
    end

    def set_link
      @link = @doc.links.find(params[:id])
    end

    def doc_path
      # If doc is associated with a project from params, redirect there
      # Otherwise, redirect to standalone doc view
      if params[:project_id]
        projects_project_doc_path(params[:project_id], @doc)
      elsif @doc.projects.any?
        projects_project_doc_path(@doc.projects.first, @doc)
      else
        projects_doc_path(@doc)
      end
    end
  end
end
