import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "tab" ]
  static values = { activeTab: String }

  switchTab(event) {
    const tabName = event.target.dataset.tab
    this.activeTabValue = tabName

    // Update button styles
    this.element.querySelectorAll("[data-action*='switchTab']").forEach(btn => {
      if (btn.dataset.tab === tabName) {
        btn.classList.add("border-primary", "text-foreground")
        btn.classList.remove("text-muted-foreground", "border-transparent")
      } else {
        btn.classList.remove("border-primary", "text-foreground")
        btn.classList.add("text-muted-foreground", "border-transparent")
      }
    })

    // Show/hide tab content
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tabName === tabName) {
        tab.classList.remove("hidden")
      } else {
        tab.classList.add("hidden")
      }
    })
  }
}
