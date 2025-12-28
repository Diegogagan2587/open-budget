class ExpensesController < ApplicationController
  before_action :set_budget_period, only: [ :new, :create ]
  before_action :set_expense, only: %i[ show edit update destroy ]


  def index
    @expenses = Expense.all
    @expenses = @expenses.where("date >= ?", params[:date_from]) if params[:date_from].present?
    @expenses = @expenses.where("date <= ?", params[:date_to])   if params[:date_to].present?
    @expenses = @expenses.where(category_id: params[:category_id]) if params[:category_id].present?
    @expenses = @expenses.where("description ILIKE ?", "%#{params[:q]}%") if params[:q].present?
  end

  # GET /expenses or /expenses.json
  def new
    @expense = @budget_period ? @budget_period.expenses.build : Expense.new
  end

  # GET /expenses/1 or /expenses/1.json
  def show
  end

  # GET /expenses/1/edit
  def edit
  end

  # POST /expenses or /expenses.json
  def create
    @expense = Expense.new(expense_params)
    
    # Auto-suggest budget_period from income_event if income_event is set and budget_period is not
    if @expense.income_event_id.present? && @expense.budget_period_id.blank?
      income_event = IncomeEvent.find(@expense.income_event_id)
      @expense.budget_period_id = income_event.budget_period_id if income_event.budget_period_id
    end

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
    old_income_event_id = @expense.income_event_id
    new_income_event_id = expense_params[:income_event_id]
    
    respond_to do |format|
      if @expense.update(expense_params)
        # If income_event_id changed and expense has a planned_expense, sync it
        if @expense.planned_expense.present?
          old_id = old_income_event_id.to_i rescue 0
          new_id = new_income_event_id.present? ? new_income_event_id.to_i : 0
          
          if new_id != old_id && new_income_event_id.present?
            @expense.planned_expense.update(income_event_id: new_income_event_id)
          end
        end
        
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
      @expense = Expense.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def expense_params
      params.expect(expense: [ :date, :amount, :description, :category_id, :budget_period_id, :income_event_id ])
    end

    def set_budget_period
      if params[:budget_period_id]
        @budget_period = BudgetPeriod.find(params[:budget_period_id])
      end
    end
end
