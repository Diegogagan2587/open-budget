module Career
  class CompaniesController < ApplicationController
    def index
      @companies = Career::Company.for_account(Current.account).order(:name)
    end

    def create
      @company = Career::Company.new(company_params)
      @company.account = Current.account

      if @company.save
        redirect_back fallback_location: career_companies_path, notice: "Company created"
      else
        redirect_back fallback_location: career_companies_path, alert: @company.errors.full_messages.to_sentence
      end
    end

    private

    def company_params
      params.require(:career_company).permit(:name, :website_url, :linkedin_url, :notes)
    end
  end
end
