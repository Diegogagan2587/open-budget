# frozen_string_literal: true

require "test_helper"

class SidebarMenuSubComponentTest < ViewComponent::TestCase
  def test_component_renders_nested_list
    rendered = render_inline(SidebarMenuSubComponent.new) { "<li>Sub</li>" }

    assert rendered.css("ul[data-slot='sidebar-menu-sub']").any?
    assert_includes rendered.to_html, "Sub"
  end
end
