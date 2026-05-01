# frozen_string_literal: true

require "test_helper"

class SidebarMenuSubComponentTest < ViewComponent::TestCase
  def test_component_renders_nested_list
    rendered = render_inline(SidebarMenuSubComponent.new) { "<li>Sub</li>" }

    assert rendered.css("ul.space-y-1").any?
    assert_includes rendered.to_html, "Sub"
  end
end
