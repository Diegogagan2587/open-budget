# frozen_string_literal: true

require "test_helper"

class SidebarMenuItemComponentTest < ViewComponent::TestCase
  def test_component_renders_list_item
    rendered = render_inline(SidebarMenuItemComponent.new) { "<a href='/'>Home</a>" }

    assert rendered.css("li[data-slot='sidebar-menu-item']").any?
    assert_includes rendered.to_html, "Home"
  end
end
