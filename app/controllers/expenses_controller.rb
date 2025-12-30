class ExpensesController < ApplicationController
  before_action :set_budget_period, only: [ :new, :create ]
  before_action :set_expense, only: %i[ show edit update destroy ]


  def index
    @expenses = Expense.for_account(Current.account).all
    @expenses = @expenses.where("date >= ?", params[:date_from]) if params[:date_from].present?
    @expenses = @expenses.where("date <= ?", params[:date_to])   if params[:date_to].present?
    @expenses = @expenses.where(category_id: params[:category_id]) if params[:category_id].present?
    @expenses = @expenses.where("description ILIKE ?", "%#{params[:q]}%") if params[:q].present?
  end

  # GET /expenses or /expenses.json
  def new
    @expense = @budget_period ? @budget_period.expenses.build : Expense.for_account(Current.account).new
    @expense.account = Current.account unless @expense.account
  end

  # GET /expenses/1 or /expenses/1.json
  def show
  end

  # GET /expenses/1/edit
  def edit
  end

  # POST /expenses or /expenses.json
  def create
    @expense = Expense.for_account(Current.account).new(expense_params)
    @expense.account = Current.account

    respond_to do |format|
      if @expense.save
        target = @expense.budget_period || @expense
        format.html { redirect_to target, notice: "Expense was successfully created." }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenses/1 or /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to @expense, notice: "Expense was successfully updated." }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1 or /expenses/1.json
  def destroy
    @expense.destroy!

    respond_to do |format|
      format.html { redirect_to expenses_path, status: :see_other, notice: "Expense was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.for_account(Current.account).find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def expense_params
      params.expect(expense: [ :date, :amount, :description, :category_id, :budget_period_id ])
    end

    def set_budget_period
      if params[:budget_period_id]
        @budget_period = BudgetPeriod.for_account(Current.account).find(params[:budget_period_id])
      end
    end
end
