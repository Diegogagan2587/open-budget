# frozen_string_literal: true

require "test_helper"

class SidebarProviderComponentTest < ViewComponent::TestCase
  def test_component_renders_sidebar_controller_wrapper
    rendered = render_inline(SidebarProviderComponent.new) do
      "<span>content</span>"
    end

    assert rendered.css("div[data-controller='sidebar']").any?
    assert_includes rendered.to_html, "content"
  end
end
