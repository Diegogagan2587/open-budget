import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "search", "linkItem"]

  toggleForm() {
    this.formTarget.classList.toggle("hidden")
    if (!this.formTarget.classList.contains("hidden")) {
      this.searchTarget.value = ""
      this.filterLinks()
      this.searchTarget.focus()
    }
  }

  filterLinks() {
    const searchTerm = this.searchTarget.value.toLowerCase()
    
    this.linkItemTargets.forEach(item => {
      const title = item.dataset.linkTitle
      const url = item.dataset.linkUrl
      const matches = title.includes(searchTerm) || url.includes(searchTerm)
      
      item.closest('form').classList.toggle('hidden', !matches)
    })
  }
}
