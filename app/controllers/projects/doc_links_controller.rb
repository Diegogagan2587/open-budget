module Projects
  class DocLinksController < ApplicationController
    before_action :set_doc
    before_action :set_link, only: [ :destroy ]

    def create
      @link = Projects::Link.for_account(Current.account).find(params[:link_id])

      if @doc.links << @link
        redirect_to projects_project_doc_path(@doc.projects.first, @doc), notice: t("projects.flash.link_added")
      else
        redirect_to projects_project_doc_path(@doc.projects.first, @doc), alert: t("projects.flash.link_add_failed")
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to projects_project_doc_path(@doc.projects.first, @doc), alert: t("projects.flash.link_already_added")
    end

    def destroy
      @doc.links.delete(@link)
      redirect_to projects_project_doc_path(@doc.projects.first, @doc), notice: t("projects.flash.link_removed")
    end

    private

    def set_doc
      @doc = Projects::Doc.for_account(Current.account).find(params[:doc_id])
    end

    def set_link
      @link = @doc.links.find(params[:id])
    end
  end
end
