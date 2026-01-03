# frozen_string_literal: true

class ActionButtonComponent < ViewComponent::Base
  def initialize(path:, label:, color: :green, method: nil, data_attributes: {}, size: :default)
    @path = path
    @label = label
    @color = color
    @method = method
    @data_attributes = data_attributes
    @size = size
  end

  def classes
    color_classes = case @color
    when :green
      "bg-green-500 hover:bg-green-600"
    when :purple
      "bg-purple-500 hover:bg-purple-600"
    when :indigo
      "bg-indigo-500 hover:bg-indigo-600"
    when :blue
      "bg-blue-500 hover:bg-blue-600"
    when :red
      "bg-red-500 hover:bg-red-600"
    else
      "bg-gray-500 hover:bg-gray-600"
    end

    base_classes = "#{color_classes} text-white rounded transition-colors flex items-center gap-2"
    
    case @size
    when :small
      "px-3 py-1 text-sm #{base_classes}"
    when :large
      "px-6 py-3 shadow-md hover:shadow-lg #{base_classes}"
    else
      "px-4 py-2 #{base_classes}"
    end
  end

  def link_options
    options = { class: classes }
    options[:data] = @data_attributes if @data_attributes.any?
    options[:method] = @method if @method
    options
  end

  def icon_path
    case @label.downcase
    when /received|apply/
      "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
    when /plan/
      "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
    else
      nil
    end
  end
end

