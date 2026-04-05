  # frozen_string_literal: true

  class Ui::LineChartCardComponent < ViewComponent::Base
    def initialize(chart_config:, title: nil, description: nil, legend_aria_label: nil, wrapper_class: nil, canvas_class: nil, preset: "shadcn-line", extra_class: nil)
      @chart_config = chart_config
      @title = title
      @description = description
      @legend_aria_label = legend_aria_label || I18n.t("reports.chart_series_legend_aria")
      @wrapper_class = wrapper_class || "min-h-[200px] sm:min-h-[260px] min-w-0 w-full overflow-x-auto"
      @canvas_class = canvas_class || "block w-full min-w-0 h-[220px] sm:h-[280px]"
      @preset = preset
      @extra_class = extra_class
    end

    def chart_config_json
      @chart_config.to_json
    end

    def show_header?
      @title.present? || @description.present?
    end

    def card_classes
      [ "rounded-xl border border-border bg-card text-card-foreground shadow-sm p-4 sm:p-6 mb-6", @extra_class ].compact.join(" ")
    end
  end
