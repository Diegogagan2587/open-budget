# frozen_string_literal: true

class SidebarGroupComponent < ViewComponent::Base
  def initialize(label: nil)
    @label = label
  end

  attr_reader :label
end
