# frozen_string_literal: true

require "test_helper"

class SidebarGroupContentComponentTest < ViewComponent::TestCase
  def test_component_renders_content_wrapper
    rendered = render_inline(SidebarGroupContentComponent.new) { "<span>inner</span>" }

    assert rendered.css("div.pl-1").any?
    assert_includes rendered.to_html, "inner"
  end
end
