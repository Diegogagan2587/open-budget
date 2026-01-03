# frozen_string_literal: true

class InventoryItemRowComponent < ViewComponent::Base
  def initialize(inventory_item:)
    @inventory_item = inventory_item
  end

  def stock_indicator_color
    case @inventory_item.stock_state
    when "in_stock"
      "bg-green-500"
    when "low"
      "bg-yellow-500"
    when "empty"
      "bg-red-500"
    else
      "bg-gray-500"
    end
  end
end

