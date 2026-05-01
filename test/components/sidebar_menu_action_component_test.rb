# frozen_string_literal: true

require "test_helper"

class SidebarMenuActionComponentTest < ViewComponent::TestCase
  def test_component_passes_through_content
    rendered = render_inline(SidebarMenuActionComponent.new) { "Action" }

    assert_includes rendered.text, "Action"
  end
end
