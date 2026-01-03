# frozen_string_literal: true

class StatusBadgeComponent < ViewComponent::Base
  def initialize(status:, type: :status)
    @status = status
    @type = type
  end

  def classes
    case @type
    when :status
      case @status
      when "pending"
        "px-2 py-1 rounded text-xs bg-yellow-100 text-yellow-800"
      when "purchased"
        "px-2 py-1 rounded text-xs bg-green-100 text-green-800"
      else
        "px-2 py-1 rounded text-xs bg-gray-100 text-gray-800"
      end
    when :stock_state
      case @status
      when "in_stock"
        "px-2 py-1 rounded text-xs bg-green-100 text-green-800"
      when "low"
        "px-2 py-1 rounded text-xs bg-yellow-100 text-yellow-800"
      when "empty"
        "px-2 py-1 rounded text-xs bg-red-100 text-red-800"
      else
        "px-2 py-1 rounded text-xs bg-gray-100 text-gray-800"
      end
    when :item_type
      "px-2 py-1 rounded text-xs bg-gray-100 text-gray-800"
    else
      "px-2 py-1 rounded text-xs bg-gray-100 text-gray-800"
    end
  end

  def display_text
    @status.humanize
  end
end

