# frozen_string_literal: true

class ViewButtonComponent < ViewComponent::Base
  def initialize(path: nil, label: "View", variant: nil, color: nil, size: :default, disabled: false, icon: nil, type: "button", method: nil, data_attributes: {}, extra_class: nil)
    @path = path
    @label = label
    @variant = variant || legacy_variant_from_color(color)
    @size = size
    @disabled = disabled
    @show_icon = icon.nil? ? legacy_show_icon_for_color(color) : icon
    @type = type
    @method = method
    @data_attributes = data_attributes
    @extra_class = extra_class
  end

  def show_icon?
    @show_icon
  end

  private

  def legacy_variant_from_color(color)
    case color&.to_sym
    when :gray
      :secondary
    when :red
      :destructive
    else
      nil
    end
  end

  def legacy_show_icon_for_color(color)
    color&.to_sym != :gray
  end
end
