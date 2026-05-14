import { Controller } from "@hotwired/stimulus"

let drawerInstance = null

export default class extends Controller {
  static targets = ["overlay", "panel", "content"]
  static values = { open: Boolean }

  connect() {
    console.log("✓ Drawer controller connected")
    drawerInstance = this
    
    // Expose to window so buttons can call it
    window.drawerOpen = (url) => {
      console.log("📂 Opening drawer with URL:", url)
      this.openDrawer(url)
    }
    
    // Listen for drawer:close event
    document.addEventListener("drawer:close", () => {
      console.log("🔒 Closing drawer via event")
      this.close()
    })
    
    // Listen for successful form submissions
    document.addEventListener("turbo:submit-end", (e) => {
      if (this.openValue && this.contentTarget.contains(e.target)) {
        console.log("✅ Form submitted, detail:", e.detail)
        if (e.detail.success) {
          console.log("📋 Form successful, closing drawer")
          setTimeout(() => this.close(), 100)
        }
      }
    })
  }

  async openDrawer(url) {
    if (!url) {
      console.error("❌ No URL provided")
      return
    }

    this.openValue = true
    
    // Show overlay and panel
    this.overlayTarget.classList.remove("hidden")
    this.panelTarget.classList.remove("hidden")
    console.log("📂 Showing drawer panel and overlay")
    
    // Trigger animation on next frame
    requestAnimationFrame(() => {
      this.panelTarget.classList.add("translate-x-0")
      this.panelTarget.classList.remove("translate-x-full")
      console.log("🎬 Animation started")
    })

    try {
      console.log("⏳ Fetching:", url)
      const response = await fetch(url, {
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const html = await response.text()
      console.log("✅ Content loaded, length:", html.length)
      this.contentTarget.innerHTML = html
    } catch (error) {
      console.error("❌ Failed to load drawer content:", error)
      this.close()
    }
  }

  close() {
    this.openValue = false
    
    // Start slide-out animation
    this.panelTarget.classList.remove("translate-x-0")
    this.panelTarget.classList.add("translate-x-full")
    console.log("🔒 Animation closing")
    
    // Hide after animation completes
    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
      this.panelTarget.classList.add("hidden")
      this.contentTarget.innerHTML = ""
      console.log("✓ Drawer fully closed")
    }, 300)
  }

  overlayClick(event) {
    if (event.target === this.overlayTarget) {
      console.log("👆 Overlay clicked")
      this.close()
    }
  }
}
