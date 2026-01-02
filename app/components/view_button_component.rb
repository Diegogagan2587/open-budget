# frozen_string_literal: true

class ViewButtonComponent < ViewComponent::Base
  def initialize(path:, label: "View", color: :blue, size: :default)
    @path = path
    @label = label
    @color = color
    @size = size
  end

  def classes
    color_classes = case @color
    when :indigo
      "bg-indigo-500 hover:bg-indigo-600 text-white"
    when :gray
      "bg-gray-200 text-gray-700 hover:bg-gray-300"
    else # :blue
      "bg-blue-500 hover:bg-blue-600 text-white"
    end

    base_classes = "#{color_classes} rounded transition-colors flex items-center gap-2"
    
    case @size
    when :small
      "px-3 py-1 text-sm #{base_classes}"
    when :large
      "px-6 py-3 #{base_classes}"
    else
      "px-4 py-2 #{base_classes}"
    end
  end

  def show_icon?
    @color != :gray
  end
end

