# frozen_string_literal: true

class Ui::BadgeComponent < ViewComponent::Base
  BASE_CLASSES = "inline-flex items-center gap-1 rounded-md border px-2 py-0.5 text-xs font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"

  VARIANT_CLASSES = {
    default: "border-transparent bg-primary text-primary-foreground",
    secondary: "border-transparent bg-secondary text-secondary-foreground",
    destructive: "border-transparent bg-destructive text-destructive-foreground",
    outline: "border-border bg-background text-foreground",
    ghost: "border-transparent bg-transparent text-muted-foreground hover:text-foreground hover:bg-accent"
  }.freeze

  def initialize(label: nil, variant: :secondary, href: nil, css_class: nil)
    @label = label
    @variant = normalize_variant(variant)
    @href = href
    @extra_class = css_class
  end

  def link?
    @href.present?
  end

  def classes
    [ BASE_CLASSES, VARIANT_CLASSES.fetch(@variant), @extra_class ].compact.join(" ")
  end

  private

  def normalize_variant(variant)
    key = variant.to_sym
    return key if VARIANT_CLASSES.key?(key)

    :secondary
  end
end
