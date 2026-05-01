# frozen_string_literal: true

class SidebarTriggerComponent < ViewComponent::Base
  def initialize(variant: :menu)
    @variant = variant.to_sym
  end

  attr_reader :variant

  def menu_variant?
    variant == :menu
  end
end
