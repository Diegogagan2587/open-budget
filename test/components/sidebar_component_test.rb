# frozen_string_literal: true

require "test_helper"

class SidebarComponentTest < ViewComponent::TestCase
  def test_component_renders_desktop_and_mobile_containers
    rendered = render_inline(SidebarComponent.new)

    assert rendered.css("aside[data-slot='sidebar']").any?
    assert rendered.css("div[data-slot='sidebar-mobile']").any?
    assert rendered.css("div[data-sidebar-target='panel']").any?
    assert rendered.css("div[data-sidebar-target='backdrop']").any?
  end
end
