module Financial
  class LiabilitiesController < ApplicationController
    before_action :set_financial_liability, only: [ :show, :edit, :update, :destroy, :charge, :record_charge, :payment, :record_payment ]
    before_action :load_charge_collections, only: [ :charge, :record_charge ]
    before_action :load_payment_accounts, only: [ :payment, :record_payment ]

    def index
      @financial_liabilities = Financial::Liability.for_account(Current.account).order(:name)
    end

    def show
    end

    def new
      @financial_liability = Financial::Liability.new
    end

    def create
      @financial_liability = Financial::Liability.for_account(Current.account).new(financial_liability_params)
      @financial_liability.account = Current.account

      if @financial_liability.save
        redirect_to finance_financial_liability_path(@financial_liability), notice: "Liability created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @financial_liability.update(financial_liability_params)
        redirect_to finance_financial_liability_path(@financial_liability), notice: "Liability updated"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @financial_liability.destroy!
      redirect_to finance_financial_liabilities_path, status: :see_other, notice: "Liability removed"
    end

    def charge
    end

    def record_charge
      service = Financial::Liabilities::RecordChargeService.call(
        liability: @financial_liability,
        amount: charge_params[:amount],
        description: charge_params[:description],
        entry_date: charge_params[:entry_date],
        category_id: charge_params[:category_id],
        budget_period_id: charge_params[:budget_period_id],
        income_event_id: charge_params[:income_event_id]
      )

      if service.success?
        redirect_to finance_financial_liability_path(@financial_liability), notice: "Charge recorded"
      else
        flash.now[:alert] = service.error_message
        render :charge, status: :unprocessable_entity
      end
    end

    def payment
    end

    def record_payment
      source_account = Financial::Asset.for_account(Current.account).find_by(id: payment_params[:financial_account_id])

      service = Financial::Liabilities::RecordPaymentService.call(
        liability: @financial_liability,
        source_account: source_account,
        amount: payment_params[:amount],
        description: payment_params[:description],
        entry_date: payment_params[:entry_date]
      )

      if service.success?
        redirect_to finance_financial_liability_path(@financial_liability), notice: "Payment recorded"
      else
        flash.now[:alert] = service.error_message
        render :payment, status: :unprocessable_entity
      end
    end

    private

    def set_financial_liability
      @financial_liability = Financial::Liability.for_account(Current.account).find(params[:id])
    end

    def financial_liability_params
      params.expect(financial_liability: [ :name, :liability_type, :status, :opening_balance, :credit_limit, :notes ])
    end

    def charge_params
      params.expect(financial_liability_charge: [
        :amount,
        :description,
        :entry_date,
        :category_id,
        :budget_period_id,
        :income_event_id
      ])
    end

    def payment_params
      params.expect(financial_liability_payment: [
        :amount,
        :description,
        :entry_date,
        :financial_account_id
      ])
    end

    def load_charge_collections
      @categories = Category.for_account(Current.account).order(:name)
      @budget_periods = BudgetPeriod.for_account(Current.account).order(start_date: :desc)
      @income_events = IncomeEvent.for_account(Current.account).by_date
    end

    def load_payment_accounts
      @financial_accounts = Financial::Asset.for_account(Current.account).active.order(:name)
    end
  end
end
