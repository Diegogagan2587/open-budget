# frozen_string_literal: true

require "test_helper"

class SidebarHeaderComponentTest < ViewComponent::TestCase
  def test_component_renders_brand_link
    rendered = render_inline(SidebarHeaderComponent.new)

    assert rendered.css("a[href='/']").any?
    assert_includes rendered.text, "Open Budget"
  end
end
