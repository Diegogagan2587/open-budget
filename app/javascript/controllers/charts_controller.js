import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { config: String }

  connect() {
    const Chart = window.Chart
    if (!Chart) return

    const configJson = this.configValue
    if (!configJson) return

    let config
    try {
      config = JSON.parse(configJson)
    } catch (_e) {
      return
    }

    const { type, data } = config
    if (!type || !data) return

    this.chart = new Chart(this.element, {
      type,
      data,
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: { display: true },
          tooltip: { enabled: true }
        },
        scales: type === "pie" || type === "doughnut" ? {} : {
          y: { beginAtZero: true }
        }
      }
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }
}
