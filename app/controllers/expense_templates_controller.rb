class ExpenseTemplatesController < ApplicationController
  before_action :set_expense_template, only: [ :show, :edit, :update, :destroy ]

  def index
    @expense_templates = ExpenseTemplate.for_account(Current.account).includes(:category).all
  end

  def show
    @planned_expenses = @expense_template.planned_expenses.includes(:income_event, :category).order(created_at: :desc)
  end

  def new
    @expense_template = ExpenseTemplate.new
  end

  def create
    @expense_template = ExpenseTemplate.for_account(Current.account).new(expense_template_params)
    @expense_template.account = Current.account

    respond_to do |format|
      if @expense_template.save
        format.html { redirect_to @expense_template, notice: t("expense_templates.flash.created") }
        format.json { render :show, status: :created, location: @expense_template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @expense_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @expense_template.update(expense_template_params)
        format.html { redirect_to @expense_template, notice: t("expense_templates.flash.updated") }
        format.json { render :show, status: :ok, location: @expense_template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @expense_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @expense_template.destroy!

    respond_to do |format|
      format.html { redirect_to expense_templates_path, status: :see_other, notice: t("expense_templates.flash.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  def set_expense_template
    @expense_template = ExpenseTemplate.for_account(Current.account).find(params[:id])
  end

  def expense_template_params
    params.expect(expense_template: [ :name, :category_id, :description, :total_amount, :frequency, :notes ])
  end
end
