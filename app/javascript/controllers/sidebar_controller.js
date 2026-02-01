import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop", "button"]

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    window.addEventListener("keydown", this.boundHandleKeydown)
    document.addEventListener("turbo:before-visit", this.closeOnTurbo)
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundHandleKeydown)
    document.removeEventListener("turbo:before-visit", this.closeOnTurbo)
    document.body.style.overflow = ""
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.isOpen()) {
      this.close()
    }
  }

  toggle() {
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.remove("-translate-x-full")
      this.panelTarget.classList.add("translate-x-0")
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("hidden")
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "true")
      this.buttonTarget.setAttribute("aria-label", this.buttonTarget.dataset.menuClose || "Close menu")
    }
    document.body.style.overflow = "hidden"
  }

  close() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.remove("translate-x-0")
      this.panelTarget.classList.add("-translate-x-full")
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("hidden")
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "false")
      this.buttonTarget.setAttribute("aria-label", this.buttonTarget.dataset.menuOpen || "Open menu")
    }
    document.body.style.overflow = ""
  }

  closeOnTurbo = () => {
    this.close()
  }

  isOpen() {
    return this.hasPanelTarget && this.panelTarget.classList.contains("translate-x-0")
  }
}
