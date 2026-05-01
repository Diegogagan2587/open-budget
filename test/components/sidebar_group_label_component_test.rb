# frozen_string_literal: true

require "test_helper"

class SidebarGroupLabelComponentTest < ViewComponent::TestCase
  def test_component_renders_heading
    rendered = render_inline(SidebarGroupLabelComponent.new) { "Main" }

    assert rendered.css("h3").any?
    assert_includes rendered.text, "Main"
  end
end
