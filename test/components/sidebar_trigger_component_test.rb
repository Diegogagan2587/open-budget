# frozen_string_literal: true

require "test_helper"

class SidebarTriggerComponentTest < ViewComponent::TestCase
  def test_component_renders_toggle_button
    rendered = render_inline(SidebarTriggerComponent.new)

    assert rendered.css("button[data-action='click->sidebar#toggle']").any?
    assert_includes rendered.text, "Toggle sidebar"
  end
end
