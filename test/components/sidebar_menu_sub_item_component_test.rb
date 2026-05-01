# frozen_string_literal: true

require "test_helper"

class SidebarMenuSubItemComponentTest < ViewComponent::TestCase
  def test_component_renders_list_item
    rendered = render_inline(SidebarMenuSubItemComponent.new) { "<a href='/reports'>Reports</a>" }

    assert rendered.css("li[data-slot='sidebar-menu-sub-item']").any?
    assert_includes rendered.to_html, "Reports"
  end
end
