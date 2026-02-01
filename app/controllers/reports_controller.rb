# frozen_string_literal: true

class ReportsController < ApplicationController
  def index
    account = Current.account
    return head :forbidden unless account

    @date_from = (params[:from].presence && Date.parse(params[:from])) || 12.months.ago.to_date
    @date_to   = (params[:to].presence && Date.parse(params[:to])) || Date.current
    @date_from, @date_to = @date_to, @date_from if @date_from > @date_to
    range = @date_from..@date_to

    expenses = Expense.for_account(account).where(date: range)

    # Expenses by month (labels and values for Chart.js)
    by_month = expenses.group("DATE_TRUNC('month', date)").order(Arel.sql("DATE_TRUNC('month', date)")).sum(:amount)
    @expenses_by_month_labels = by_month.keys.map { |d| I18n.l(d.to_date, format: "%b %Y") }
    @expenses_by_month_values = by_month.values.map(&:to_f)

    # Expenses by category
    by_category = expenses.joins(:category).group("categories.name").order(Arel.sql("SUM(expenses.amount) DESC")).sum(:amount)
    @expenses_by_category_labels = by_category.keys
    @expenses_by_category_values = by_category.values.map(&:to_f)

    # Income vs expenses (for the same date range: income by effective date)
    income_total = IncomeEvent.for_account(account).where(
      "COALESCE(received_date, expected_date) BETWEEN ? AND ?", @date_from, @date_to
    ).sum(Arel.sql("COALESCE(received_amount, expected_amount)"))
    expenses_total = expenses.sum(:amount)
    @income_vs_expenses_labels = [ I18n.t("reports.income"), I18n.t("reports.expenses") ]
    @income_vs_expenses_values = [ income_total.to_f, expenses_total.to_f ]

    # Chart.js configs for Stimulus (type + data.labels + data.datasets)
    @chart_expenses_over_time = {
      type: "bar",
      data: {
        labels: @expenses_by_month_labels,
        datasets: [ { label: I18n.t("reports.expenses"), data: @expenses_by_month_values, backgroundColor: "rgba(59, 130, 246, 0.5)", borderColor: "rgb(59, 130, 246)" } ]
      }
    }
    @chart_by_category = {
      type: "bar",
      data: {
        labels: @expenses_by_category_labels,
        datasets: [ { label: I18n.t("reports.expenses"), data: @expenses_by_category_values, backgroundColor: [ "rgba(34, 197, 94, 0.5)", "rgba(234, 179, 8, 0.5)", "rgba(239, 68, 68, 0.5)", "rgba(139, 92, 246, 0.5)", "rgba(236, 72, 153, 0.5)" ], borderColor: [ "rgb(34, 197, 94)", "rgb(234, 179, 8)", "rgb(239, 68, 68)", "rgb(139, 92, 246)", "rgb(236, 72, 153)" ] } ]
      }
    }
    @chart_income_vs_expenses = {
      type: "bar",
      data: {
        labels: @income_vs_expenses_labels,
        datasets: [ { label: I18n.t("reports.amount"), data: @income_vs_expenses_values, backgroundColor: [ "rgba(34, 197, 94, 0.5)", "rgba(239, 68, 68, 0.5)" ], borderColor: [ "rgb(34, 197, 94)", "rgb(239, 68, 68)" ] } ]
      }
    }
  end
end
