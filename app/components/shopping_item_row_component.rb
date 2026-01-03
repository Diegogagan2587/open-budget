# frozen_string_literal: true

class ShoppingItemRowComponent < ViewComponent::Base
  def initialize(shopping_item:)
    @shopping_item = shopping_item
  end
end

