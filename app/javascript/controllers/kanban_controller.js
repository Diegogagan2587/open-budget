import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column", "card", "count"]

  connect() {
    this.draggedCard = null
  }

  dragStart(event) {
    this.draggedCard = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggedCard.dataset.taskId)
    this.draggedCard.classList.add("opacity-60")
  }

  dragEnd() {
    if (this.draggedCard) {
      this.draggedCard.classList.remove("opacity-60")
    }
    this.draggedCard = null
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  drop(event) {
    event.preventDefault()
    const column = event.currentTarget
    const status = column.dataset.status
    if (!this.draggedCard || !status) return

    const cardsContainer = column.querySelector(".p-3")
    if (cardsContainer) {
      cardsContainer.appendChild(this.draggedCard)
    }

    this.updateCounts()
    this.persistStatus(this.draggedCard, status)
  }

  updateCounts() {
    this.columnTargets.forEach((column) => {
      const status = column.dataset.status
      const countTarget = this.countTargets.find((el) => el.dataset.status === status)
      if (!countTarget) return
      const cards = column.querySelectorAll('[data-kanban-target="card"]')
      countTarget.textContent = cards.length
    })
  }

  persistStatus(card, status) {
    const url = card.dataset.taskUrl
    if (!url) return

    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      body: JSON.stringify({ task: { status } })
    }).catch(() => {
      // If request fails, counts will still be correct but server state won't update.
      // A full refresh will show the previous state.
    })
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute("content") : ""
  }
}
