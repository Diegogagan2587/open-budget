module ApplicationHelper
  def report_period_options
    ReportPeriodBuckets::PERIODS.map { |p| [ I18n.t("reports.period_#{p}"), p ] }
  end

  def report_period_options_with_total
    [ [ I18n.t("reports.period_total"), "none" ] ] + report_period_options
  end

  def report_trend_period_options
    ReportPeriodBuckets::TREND_PERIODS.map { |p| [ I18n.t("reports.period_#{p}"), p ] }
  end
end
