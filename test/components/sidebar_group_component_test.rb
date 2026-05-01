# frozen_string_literal: true

require "test_helper"

class SidebarGroupComponentTest < ViewComponent::TestCase
  def test_component_renders_section_wrapper
    rendered = render_inline(SidebarGroupComponent.new) { "<span>group</span>" }

    assert rendered.css("section.mb-4").any?
    assert_includes rendered.to_html, "group"
  end
end
