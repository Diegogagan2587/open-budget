# frozen_string_literal: true

require "test_helper"

class SidebarContentComponentTest < ViewComponent::TestCase
  def test_component_renders_nav_wrapper
    rendered = render_inline(SidebarContentComponent.new) { "<span>nav</span>" }

    assert rendered.css("nav").any?
    assert_includes rendered.to_html, "nav"
  end
end
