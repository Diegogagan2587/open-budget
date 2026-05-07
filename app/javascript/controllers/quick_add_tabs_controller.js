import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { activeTab: String }

  connect() {
    // Show first tab by default
    this.selectTab(this.tabTargets[0])
  }

  selectTab(tab) {
    const tabElement = tab?.currentTarget || tab

    // Hide all panels
    this.panelTargets.forEach((panel) => {
      panel.classList.add("hidden")
    })

    // Deactivate all tabs
    this.tabTargets.forEach((t) => {
      t.classList.remove("bg-accent", "text-accent-foreground")
      t.classList.add("text-muted-foreground")
    })

    // Activate clicked tab
    tabElement.classList.remove("text-muted-foreground")
    tabElement.classList.add("bg-accent", "text-accent-foreground")

    // Show corresponding panel
    const panelId = tabElement.dataset.panel
    const panel = this.panelTargets.find((p) => p.id === panelId)
    if (panel) {
      panel.classList.remove("hidden")
    }
  }
}
