module ApplicationHelper
  # Returns the current page title for the navbar (e.g. "Expenses", "New expense").
  # Uses content_for(:nav_title) if set, otherwise derives from controller/action and locale.
  def nav_page_title
    return content_for(:nav_title) if content_for?(:nav_title)

    path = controller_path.tr("/", ".")
    action = action_name

    # Reports use custom locale keys (by_date_title, etc.)
    if controller_path == "reports"
      return t("reports.index.title") if action == "index"
      return t("reports.by_date_title") if action == "by_date"
      return t("reports.spending_by_category_title") if action == "spending_by_category"
      return t("reports.category_trends_title") if action == "category_trends"
    end

    # Standard key: e.g. expenses.index.title, budget_periods.show.title
    key = "#{path}.#{action}.title"
    return t(key) if I18n.exists?(key)

    # Fallback: nav section label by controller
    nav_key = case controller_path
    when "dashboard" then "dashboard"
    when "budget_periods" then "budgets"
    when "income_events" then "incomes"
    when "expenses" then "expenses"
    when "categories" then "categories"
    when "task/areas", "task/recurring_tasks" then "tasks"
    when "reports" then "reports"
    when "accounts", "account_memberships" then "accounts"
    when "settings" then "settings"
    when "expense_templates" then "expenses" # or use expense_templates.index.title
    when "shopping_items" then "nav.dashboard" # no nav link; dashboard has shopping_list_title
    when "inventory_items" then "nav.dashboard"
    when "planned_expenses" then "incomes"
    else nil
    end

    nav_key ? t("nav.#{nav_key}") : t("nav.dashboard")
  end

  def report_period_options
    ReportPeriodBuckets::PERIODS.map { |p| [ I18n.t("reports.period_#{p}"), p ] }
  end

  def report_period_options_with_total
    [ [ I18n.t("reports.period_total"), "none" ] ] + report_period_options
  end

  def report_trend_period_options
    ReportPeriodBuckets::TREND_PERIODS.map { |p| [ I18n.t("reports.period_#{p}"), p ] }
  end

  def render_markdown(text)
    return "" if text.blank?
    
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(hard_wrap: true),
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true
    )
    
    markdown.render(text)
  end
end
