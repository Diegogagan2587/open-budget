# frozen_string_literal: true

class Reports::FilterComponent < ViewComponent::Base
  FILTER_KEYS = %w[from to period].freeze

  def initialize(url:, date_from:, date_to:, period: nil, period_options: [], params_hash:, show_period: true)
    @url = url
    @date_from = date_from
    @date_to = date_to
    @period = period
    @period_options = period_options
    @params_hash = params_hash.to_h.stringify_keys
    @show_period = show_period
  end

  def from_value
    active_params["from"].presence || @date_from
  end

  def to_value
    active_params["to"].presence || @date_to
  end

  def selected_period
    active_params["period"].presence || @period
  end

  def show_period?
    @show_period
  end

  def form_grid_class
    return "grid grid-cols-1 gap-3 md:grid-cols-4 md:items-end" if show_period?

    "grid grid-cols-1 gap-3 md:grid-cols-3 md:items-end"
  end

  def active_filters
    filters = []
    if active_params["from"].present?
      filters << {
        key: "from",
        label: I18n.t("reports.period_from"),
        value: active_params["from"],
        clear_url: url_for_query(active_params.except("from"))
      }
    end

    if active_params["to"].present?
      filters << {
        key: "to",
        label: I18n.t("reports.period_to"),
        value: active_params["to"],
        clear_url: url_for_query(active_params.except("to"))
      }
    end

    return filters unless show_period? && active_params["period"].present?

    filters << {
      key: "period",
      label: I18n.t("reports.grouped_by"),
      value: period_label(active_params["period"]),
      clear_url: url_for_query(active_params.except("period"))
    }
    filters
  end

  def reset_url
    @url
  end

  private

  def active_params
    keys = show_period? ? FILTER_KEYS : FILTER_KEYS - [ "period" ]
    @active_params ||= keys.index_with { |key| @params_hash[key] }.compact_blank
  end

  def period_label(value)
    @period_options.to_h.invert.fetch(value, value)
  end

  def url_for_query(query)
    return @url if query.blank?

    separator = @url.include?("?") ? "&" : "?"
    "#{@url}#{separator}#{query.to_query}"
  end
end
