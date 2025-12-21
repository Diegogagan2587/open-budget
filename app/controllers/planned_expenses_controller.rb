class PlannedExpensesController < ApplicationController
  before_action :set_income_event
  before_action :set_planned_expense, only: [ :show, :edit, :update, :destroy, :apply ]

  def index
    @planned_expenses = @income_event.planned_expenses_ordered
    @running_balance = @income_event.received_amount || @income_event.expected_amount
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @planned_expense }
    end
  end

  def new
    @planned_expense = @income_event.planned_expenses.build
    @expense_templates = ExpenseTemplate.includes(:category).all
  end

  def create
    @planned_expense = @income_event.planned_expenses.build(planned_expense_params)
    @planned_expense.position ||= (@income_event.planned_expenses.maximum(:position) || 0) + 1

    respond_to do |format|
      if @planned_expense.save
        format.html { redirect_to income_event_planned_expenses_path(@income_event), notice: "Planned expense was successfully created." }
        format.json { render :show, status: :created, location: [ @income_event, @planned_expense ] }
      else
        @expense_templates = ExpenseTemplate.includes(:category).all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @planned_expense.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @expense_templates = ExpenseTemplate.includes(:category).all
  end

  def update
    respond_to do |format|
      if @planned_expense.update(planned_expense_params)
        format.html { redirect_to income_event_planned_expenses_path(@income_event), notice: "Planned expense was successfully updated." }
        format.json { render :show, status: :ok, location: [ @income_event, @planned_expense ] }
      else
        @expense_templates = ExpenseTemplate.includes(:category).all
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @planned_expense.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @planned_expense.destroy!

    respond_to do |format|
      format.html { redirect_to income_event_planned_expenses_path(@income_event), status: :see_other, notice: "Planned expense was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def apply
    @planned_expense.apply!
    redirect_to income_event_planned_expenses_path(@income_event), notice: "Planned expense was successfully applied."
  end

  private

  def set_income_event
    @income_event = IncomeEvent.find(params[:income_event_id])
  end

  def set_planned_expense
    @planned_expense = @income_event.planned_expenses.find(params[:id])
  end

  def planned_expense_params
    params.expect(planned_expense: [ :category_id, :description, :amount, :notes, :status, :position, :expense_template_id ])
  end
end
