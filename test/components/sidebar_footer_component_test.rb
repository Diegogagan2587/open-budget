# frozen_string_literal: true

require "test_helper"

class SidebarFooterComponentTest < ViewComponent::TestCase
  def test_component_renders_footer_container
    rendered = render_inline(SidebarFooterComponent.new)

    assert rendered.css("div.mt-auto").any?
  end
end
