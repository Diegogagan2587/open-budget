# frozen_string_literal: true

require "test_helper"

class SidebarMenuBadgeComponentTest < ViewComponent::TestCase
  def test_component_renders_badge_span
    rendered = render_inline(SidebarMenuBadgeComponent.new) { "3" }

    assert rendered.css("div[data-slot='sidebar-menu-badge']").any?
    assert_includes rendered.text, "3"
  end
end
