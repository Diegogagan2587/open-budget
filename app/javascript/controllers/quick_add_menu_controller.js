import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "fabButton", "menuButton" ]
  static values = { modalOpen: Boolean }

  connect() {
    this.modalOpenValue = false
    // Listen for turbo:submit-end to close modal on successful form submission
    const container = document.getElementById("quick-add-modal-container")
    if (container) {
      container.addEventListener("turbo:submit-end", this.handleFormSubmit.bind(this))
    }
  }

  disconnect() {
    const container = document.getElementById("quick-add-modal-container")
    if (container) {
      container.removeEventListener("turbo:submit-end", this.handleFormSubmit.bind(this))
    }
  }

  handleFormSubmit(event) {
    // If form was successful (2xx response), close modal
    if (event.detail.formSubmission.result.statusCode >= 200 && event.detail.formSubmission.result.statusCode < 300) {
      this.closeModal()
    }
  }

  toggleModal(event) {
    if (event) event.preventDefault()
    if (this.modalOpenValue) {
      this.closeModal()
    } else {
      // On mobile, show a small action menu next to the FAB so users can pick Financial/Task/Doc
      const isMobile = window.matchMedia && window.matchMedia('(max-width: 767px)').matches
      if (isMobile) {
        this.openMobileMenu(event?.currentTarget || null)
      } else {
        this.openFinancial()
      }
    }
  }

  openMobileMenu(fabEl) {
    // Prevent multiple menus
    if (document.getElementById('quick-add-mobile-menu')) return

    const menu = document.createElement('div')
    menu.id = 'quick-add-mobile-menu'
    menu.className = 'fixed bottom-20 right-6 z-50 flex flex-col items-end gap-2'

    const makeBtn = (label, handler) => {
      const btn = document.createElement('button')
      btn.type = 'button'
      btn.className = 'inline-flex items-center gap-2 px-3 py-2 rounded-md bg-primary text-primary-foreground hover:bg-primary/90 transition-colors font-medium text-sm'
      btn.textContent = label
      btn.addEventListener('click', e => {
        e.preventDefault()
        handler(e)
        this.closeMobileMenu()
      })
      return btn
    }

    menu.appendChild(makeBtn('💰 Add', () => this.openFinancial()))
    menu.appendChild(makeBtn('✓ Task', () => this.openTasks()))
    menu.appendChild(makeBtn('📄 Doc', () => this.openDocs()))

    document.body.appendChild(menu)

    // Close when clicking outside
    this._mobileMenuOutsideHandler = (ev) => {
      if (!menu.contains(ev.target) && !(fabEl && fabEl.contains(ev.target))) {
        this.closeMobileMenu()
      }
    }
    setTimeout(() => window.addEventListener('click', this._mobileMenuOutsideHandler))
  }

  closeMobileMenu() {
    const menu = document.getElementById('quick-add-mobile-menu')
    if (menu) menu.remove()
    if (this._mobileMenuOutsideHandler) {
      window.removeEventListener('click', this._mobileMenuOutsideHandler)
      this._mobileMenuOutsideHandler = null
    }
  }

  openFinancial(event) {
    if (event) event.preventDefault()
    this.loadModal("/quick-add/financial")
  }

  openTasks(event) {
    if (event) event.preventDefault()
    this.loadModal("/quick-add/task")
  }

  openDocs(event) {
    if (event) event.preventDefault()
    this.loadModal("/quick-add/doc")
  }

  loadModal(url) {
    this.modalOpenValue = true
    fetch(url, {
      headers: { "Accept": "text/html" }
    })
      .then(r => r.text())
      .then(html => {
        const modalContainer = document.getElementById("quick-add-modal-container") || this.createModalContainer()
        modalContainer.innerHTML = html
      })
      .catch(err => {
        console.error("Error loading modal:", err)
        this.closeModal()
      })
  }

  closeModal() {
    this.modalOpenValue = false
    const modal = document.getElementById("quick-add-modal-container")
    if (modal) {
      modal.innerHTML = ""
    }
  }

  createModalContainer() {
    const container = document.createElement("div")
    container.id = "quick-add-modal-container"
    document.body.appendChild(container)
    return container
  }
}
