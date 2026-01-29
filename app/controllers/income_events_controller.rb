class IncomeEventsController < ApplicationController
  before_action :set_income_event, only: [ :show, :edit, :update, :destroy, :receive, :apply_all ]
  before_action :set_budget_period, only: [ :index, :new, :create ]

  def index
    @income_events = if @budget_period
      @budget_period.income_events.by_date
    else
      IncomeEvent.for_account(Current.account).by_date
    end

    # Group by month/year for display
    @grouped_events = @income_events.group_by { |ie|
      ie.expected_date.beginning_of_month
    }.sort_by { |month, _| month }.reverse

    # Support month filter via params
    @selected_month = nil
    if params[:month].present?
      begin
        @selected_month = Date.parse(params[:month])
        @grouped_events = @grouped_events.select { |month, _| month == @selected_month.beginning_of_month }
      rescue ArgumentError
        # Invalid date format, ignore filter
        @selected_month = nil
      end
    end

    # Get available months for the selector
    @available_months = @income_events.map { |ie| ie.expected_date.beginning_of_month }.uniq.sort.reverse
  end

  def show
    @planned_expenses = @income_event.planned_expenses_ordered
    @direct_expenses = @income_event.expenses.where(planned_expense_id: nil).order(date: :desc)
  end

  def new
    @income_event = @budget_period ? @budget_period.income_events.build : IncomeEvent.new
  end

  def create
    @income_event = IncomeEvent.for_account(Current.account).new(income_event_params)
    @income_event.account = Current.account
    @income_event.budget_period = @budget_period if @budget_period

    respond_to do |format|
      if @income_event.save
        format.html { redirect_to @income_event, notice: t("income_events.flash.created") }
        format.json { render :show, status: :created, location: @income_event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @income_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @income_event.update(income_event_params)
        format.html { redirect_to @income_event, notice: t("income_events.flash.updated") }
        format.json { render :show, status: :ok, location: @income_event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @income_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @income_event.destroy!

    respond_to do |format|
      format.html { redirect_to income_events_path, status: :see_other, notice: t("income_events.flash.destroyed") }
      format.json { head :no_content }
    end
  end

  def receive
    if request.patch? || request.put?
      if @income_event.update(receive_params.merge(status: "received"))
        redirect_to @income_event, notice: t("income_events.flash.marked_received")
      else
        render :receive, status: :unprocessable_entity
      end
    end
  end

  def apply_all
    @income_event.apply_all!
    redirect_to @income_event, notice: t("income_events.flash.applied_all")
  end

  private

  def set_income_event
    @income_event = IncomeEvent.for_account(Current.account).find(params[:id])
  end

  def set_budget_period
    @budget_period = BudgetPeriod.for_account(Current.account).find(params[:budget_period_id]) if params[:budget_period_id]
  end

  def income_event_params
    params.expect(income_event: [ :expected_date, :expected_amount, :description, :status, :budget_period_id ])
  end

  def receive_params
    params.expect(income_event: [ :received_date, :received_amount ])
  end
end
