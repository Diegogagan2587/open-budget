# frozen_string_literal: true

require "test_helper"

class SidebarMenuComponentTest < ViewComponent::TestCase
  def test_component_renders_list_wrapper
    rendered = render_inline(SidebarMenuComponent.new) { "<li>Item</li>" }

    assert rendered.css("ul[data-slot='sidebar-menu']").any?
    assert_includes rendered.to_html, "Item"
  end
end
