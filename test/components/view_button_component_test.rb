# frozen_string_literal: true

require "test_helper"

class ViewButtonComponentTest < ViewComponent::TestCase
  def test_renders_default_shadcn_like_button_as_link
    result = render_inline(ViewButtonComponent.new(path: "/items/1"))
    anchor = result.css("a").first

    assert anchor
    assert_includes anchor["class"], "inline-flex"
    assert_includes anchor["class"], "bg-primary"
    assert_includes anchor["class"], "h-9"
    assert_selector "svg"
  end

  def test_maps_legacy_gray_color_to_secondary_and_hides_icon
    result = render_inline(ViewButtonComponent.new(path: "/items", color: :gray, label: "Back"))
    anchor = result.css("a").first

    assert anchor
    assert_includes anchor["class"], "bg-secondary"
    assert_includes anchor["class"], "text-secondary-foreground"
    assert_no_selector "svg"
  end

  def test_supports_shadcn_variant_and_size
    result = render_inline(ViewButtonComponent.new(path: "/delete", variant: :destructive, size: :sm, label: "Delete", icon: false))
    anchor = result.css("a").first

    assert anchor
    assert_includes anchor["class"], "bg-destructive"
    assert_includes anchor["class"], "h-8"
    assert_includes anchor["class"], "px-3"
  end

  def test_renders_as_button_when_no_path
    result = render_inline(ViewButtonComponent.new(label: "Save", icon: false))

    assert_selector "button[type='button']", text: "Save"
  end
end
