class BudgetPeriodsController < ApplicationController
  before_action :set_budget_period, only: [ :show, :edit, :update, :destroy ]

  def index
    @budget_periods = BudgetPeriod.for_account(Current.account).order(start_date: :desc)
  end

  def show
    @income_events = @budget_period.income_events_ordered
    @planned_expenses = @budget_period
      .planned_expenses
      .includes(:category, :income_event, :expense_template)
      .references(:income_event)
      .order(
        Arel.sql("income_events.expected_date ASC"),
        Arel.sql("COALESCE(planned_expenses.position, 2147483647) ASC"),
        Arel.sql("planned_expenses.created_at ASC")
      )
  end

  def new
    @budget_period = BudgetPeriod.new
  end

  def create
    @budget_period = BudgetPeriod.for_account(Current.account).new(budget_period_params)
    @budget_period.account = Current.account

    respond_to do |format|
      if @budget_period.save
        format.html { redirect_to @budget_period, notice: "Budget period was successfully created." }
        format.json { render :show, status: :created, location: @budget_period }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @budget_period.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @budget_period.update(budget_period_params)
        format.html { redirect_to @budget_period, notice: "Budget period was successfully updated." }
        format.json { render :show, status: :ok, location: @budget_period }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @budget_period.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @budget_period.destroy!

    respond_to do |format|
      format.html { redirect_to budget_periods_path, status: :see_other, notice: "Budget period was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_budget_period
    @budget_period = BudgetPeriod.for_account(Current.account).find(params[:id])
  end

  def budget_period_params
    params.expect(budget_period: [ :name, :period_type, :start_date, :end_date, :total_amount ])
  end
end
