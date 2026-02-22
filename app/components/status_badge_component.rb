# frozen_string_literal: true

class StatusBadgeComponent < ViewComponent::Base
  def initialize(status:, type: :status, translation_scope: nil)
    @status = status
    @type = type
    @translation_scope = translation_scope
  end

  def classes
    case @type
    when :status
      case @status
      when "pending", "backlog"
        "px-2 py-1 rounded text-xs bg-slate-100 text-slate-800"
      when "blocked"
        "px-2 py-1 rounded text-xs bg-red-100 text-red-800"
      when "in_progress"
        "px-2 py-1 rounded text-xs bg-blue-100 text-blue-800"
      when "in_review"
        "px-2 py-1 rounded text-xs bg-purple-100 text-purple-800"
      when "done", "purchased"
        "px-2 py-1 rounded text-xs bg-green-100 text-green-800"
      when "cancelled"
        "px-2 py-1 rounded text-xs bg-gray-400 text-gray-700"
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
    if @translation_scope
      I18n.t("#{@translation_scope}.#{@status}", default: @status.humanize)
    else
      @status.humanize
    end
  end
end
