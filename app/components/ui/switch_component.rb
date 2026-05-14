# frozen_string_literal: true

module Ui
  class SwitchComponent < ViewComponent::Base
    BASE_CLASSES = "group peer inline-flex h-5 w-9 shrink-0 cursor-pointer items-center rounded-full border-2 border-transparent bg-input transition-colors outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background disabled:cursor-not-allowed disabled:opacity-50 data-[state=checked]:bg-primary data-[state=unchecked]:bg-input".freeze
    THUMB_CLASSES = "pointer-events-none block h-4 w-4 rounded-full bg-white shadow-sm ring-0 transition-transform group-data-[state=checked]:translate-x-4 group-data-[state=unchecked]:translate-x-0".freeze

    def initialize(id:, checked: false, disabled: false, aria_label: nil, data: {}, css_class: nil)
      @id = id
      @checked = checked
      @disabled = disabled
      @aria_label = aria_label
      @data = data
      @extra_class = css_class
    end

    def button_attributes
      {
        id: @id,
        type: "button",
        role: "switch",
        "aria-checked": @checked,
        "aria-label": @aria_label,
        disabled: @disabled,
        data: @data.presence,
        class: [ BASE_CLASSES, @extra_class ].compact.join(" ")
      }.compact
    end

    def state
      @checked ? "checked" : "unchecked"
    end
  end
end
