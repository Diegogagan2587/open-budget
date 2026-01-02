# frozen_string_literal: true

class DeleteButtonComponent < ViewComponent::Base
  def initialize(path:, label: "Delete", confirm_message: "Are you sure?", size: :default)
    @path = path
    @label = label
    @confirm_message = confirm_message
    @size = size
  end

  def classes
    base_classes = "bg-red-500 text-white rounded hover:bg-red-600 transition-colors flex items-center gap-2"
    
    case @size
    when :small
      "px-3 py-1 text-sm #{base_classes}"
    when :large
      "px-6 py-3 #{base_classes}"
    else
      "px-4 py-2 #{base_classes}"
    end
  end

  def data_attributes
    {
      turbo_method: :delete,
      turbo_confirm: @confirm_message
    }
  end
end

