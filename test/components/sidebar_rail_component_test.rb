# frozen_string_literal: true

require "test_helper"

class SidebarRailComponentTest < ViewComponent::TestCase
  def test_component_renders_rail_placeholder
    rendered = render_inline(SidebarRailComponent.new)

    assert rendered.css("div[data-slot='sidebar-rail']").any?
  end
end
