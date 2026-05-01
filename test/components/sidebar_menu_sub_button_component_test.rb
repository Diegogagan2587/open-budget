# frozen_string_literal: true

require "test_helper"

class SidebarMenuSubButtonComponentTest < ViewComponent::TestCase
  def test_component_passes_through_content
    rendered = render_inline(SidebarMenuSubButtonComponent.new) { "Sub button" }

    assert_includes rendered.text, "Sub button"
  end
end
