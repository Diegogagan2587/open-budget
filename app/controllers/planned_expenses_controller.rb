class PlannedExpensesController < ApplicationController
  before_action :set_income_event
  before_action :set_planned_expense, only: [ :show, :edit, :update, :destroy, :apply, :move ]

  def index
    @planned_expenses = @income_event.planned_expenses_ordered
    @running_balance = @income_event.received_amount || @income_event.expected_amount
    @income_events = IncomeEvent.all.order(:expected_date)
  end

  def show
    @income_events = IncomeEvent.all.order(:expected_date)
    respond_to do |format|
      format.html
      format.json { render json: @planned_expense }
    end
  end

  def new
    @planned_expense = @income_event.planned_expenses.build
    @expense_templates = ExpenseTemplate.includes(:category).all
    @income_events = IncomeEvent.all.order(:expected_date)
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
        @income_events = IncomeEvent.all.order(:expected_date)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @planned_expense.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @expense_templates = ExpenseTemplate.includes(:category).all
    @income_events = IncomeEvent.all.order(:expected_date)
  end

  def update
    old_income_event = @income_event
    new_income_event_id = planned_expense_params[:income_event_id]
    
    respond_to do |format|
      if @planned_expense.update(planned_expense_params)
        # If income_event_id changed, redirect to the new income event
        if new_income_event_id.present? && new_income_event_id.to_i != old_income_event.id
          new_income_event = IncomeEvent.find(new_income_event_id)
          # Update position if moving to a new income event
          if @planned_expense.position.nil?
            @planned_expense.update(position: (new_income_event.planned_expenses.maximum(:position) || 0) + 1)
          end
          format.html { redirect_to income_event_planned_expenses_path(new_income_event), notice: "Planned expense was successfully moved and updated." }
        else
          format.html { redirect_to income_event_planned_expenses_path(@income_event), notice: "Planned expense was successfully updated." }
        end
        format.json { render :show, status: :ok, location: [ @income_event, @planned_expense ] }
      else
        @expense_templates = ExpenseTemplate.includes(:category).all
        @income_events = IncomeEvent.all.order(:expected_date)
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

  def move
    target_income_event_id = params[:target_income_event_id]
    
    unless target_income_event_id.present?
      redirect_to income_event_planned_expenses_path(@income_event), alert: "Please select a target income event."
      return
    end

    target_income_event = IncomeEvent.find(target_income_event_id)
    
    if target_income_event.id == @income_event.id
      redirect_to income_event_planned_expenses_path(@income_event), alert: "The planned expense is already assigned to this income event."
      return
    end

    old_income_event = @income_event
    @planned_expense.update(income_event_id: target_income_event.id)
    
    # Update position if needed
    if @planned_expense.position.nil?
      @planned_expense.update(position: (target_income_event.planned_expenses.maximum(:position) || 0) + 1)
    end

    redirect_to income_event_planned_expenses_path(target_income_event), notice: "Planned expense was successfully moved to #{target_income_event.description}."
  end

  private

  def set_income_event
    @income_event = IncomeEvent.find(params[:income_event_id])
  end

  def set_planned_expense
    @planned_expense = @income_event.planned_expenses.find(params[:id])
  end

  def planned_expense_params
    params.expect(planned_expense: [ :category_id, :description, :amount, :notes, :status, :position, :expense_template_id, :income_event_id ])
  end
end
