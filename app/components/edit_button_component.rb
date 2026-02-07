# frozen_string_literal: true

class EditButtonComponent < ViewComponent::Base
  def initialize(path:, label: "Edit", size: :default, extra_class: nil)
    @path = path
    @label = label
    @size = size
    @extra_class = extra_class
  end

  def classes
    base_classes = "bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors flex items-center gap-2"

    size_classes = case @size
    when :small
      "px-3 py-1 text-sm #{base_classes}"
    when :large
      "px-6 py-3 #{base_classes}"
    else
      "px-4 py-2 #{base_classes}"
    end
    [size_classes, @extra_class].compact.join(" ")
  end
end
