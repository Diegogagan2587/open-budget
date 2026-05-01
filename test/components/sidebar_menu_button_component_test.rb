# frozen_string_literal: true

require "test_helper"

class SidebarMenuButtonComponentTest < ViewComponent::TestCase
  def test_component_passes_through_content
    rendered = render_inline(SidebarMenuButtonComponent.new) { "Button" }

    assert_includes rendered.text, "Button"
  end
end
