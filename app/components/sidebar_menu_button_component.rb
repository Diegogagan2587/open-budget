# frozen_string_literal: true

class SidebarMenuButtonComponent < ViewComponent::Base
  def initialize(href: nil, active: false, class_name: nil)
    @href = href
    @active = active
    @class_name = class_name
  end

  attr_reader :href, :active, :class_name

  def classes
    base = "peer/menu-button group/menu-button relative flex w-full items-center gap-2 overflow-hidden rounded-md border border-transparent px-2 py-1.5 text-left text-sm text-sidebar-foreground outline-hidden transition-all hover:border-sidebar-border hover:bg-sidebar-accent/55 hover:text-foreground focus-visible:ring-2 focus-visible:ring-sidebar-ring disabled:pointer-events-none disabled:opacity-50 aria-disabled:pointer-events-none aria-disabled:opacity-50 data-[active=true]:border-sidebar-border data-[active=true]:bg-sidebar-accent/70 data-[active=true]:text-primary [&_svg]:size-4 [&_svg]:shrink-0"
    [ base, class_name ].compact.join(" ")
  end
end
