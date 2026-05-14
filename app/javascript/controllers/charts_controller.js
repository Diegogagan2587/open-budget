import { Controller } from "@hotwired/stimulus"

function isPlainObject(item) {
  return Boolean(item) && typeof item === "object" && !Array.isArray(item)
}

function deepMerge(target, ...sources) {
  const out = { ...target }
  for (const source of sources) {
    if (!isPlainObject(source)) continue
    for (const key of Object.keys(source)) {
      const sv = source[key]
      const tv = out[key]
      if (isPlainObject(sv) && isPlainObject(tv)) {
        out[key] = deepMerge(tv, sv)
      } else {
        out[key] = sv
      }
    }
  }
  return out
}

function resolveHslVar(cssName) {
  const raw = getComputedStyle(document.documentElement).getPropertyValue(cssName).trim()
  return raw ? `hsl(${raw})` : undefined
}

function resolveHslVarAlpha(cssName, alpha) {
  const raw = getComputedStyle(document.documentElement).getPropertyValue(cssName).trim()
  return raw ? `hsl(${raw} / ${alpha})` : undefined
}

function chartAreaWidth(canvas) {
  const el = canvas?.parentElement
  return el?.clientWidth || canvas?.clientWidth || 0
}

function applyShadcnLineResponsive(chart, useCanvasLegend) {
  if (!chart?.canvas) return
  const w = chartAreaWidth(chart.canvas)
  const compact = w < 640
  const xTicks = isPlainObject(chart.options?.scales?.x?.ticks) ? chart.options.scales.x.ticks : null

  if (useCanvasLegend) {
    chart.options ||= {}
    chart.options.plugins = isPlainObject(chart.options.plugins) ? chart.options.plugins : {}
    chart.options.plugins.legend = isPlainObject(chart.options.plugins.legend) ? chart.options.plugins.legend : {}

    const legend = chart.options.plugins.legend
    legend.display = true
    legend.labels = isPlainObject(legend.labels) ? legend.labels : {}
    legend.labels.font = isPlainObject(legend.labels.font) ? legend.labels.font : {}
    legend.labels.font.size = compact ? 10 : 12
    legend.labels.padding = compact ? 10 : 16
    legend.labels.boxWidth = compact ? 10 : 12
    legend.labels.boxHeight = compact ? 6 : 8
  }

  if (!xTicks) return
  xTicks.maxRotation = compact ? 45 : 0
  xTicks.minRotation = 0
  xTicks.autoSkip = true
  xTicks.maxTicksLimit = compact ? 8 : 24
}

function shadcnLinePreset(useCanvasLegend) {
  const border = resolveHslVar("--border")
  const gridMuted = resolveHslVarAlpha("--muted-foreground", 0.2) || resolveHslVarAlpha("--border", 0.25) || border
  const mutedFg = resolveHslVar("--muted-foreground")
  const card = resolveHslVar("--card") || resolveHslVar("--background")
  const fg = resolveHslVar("--foreground")
  const muted = resolveHslVar("--muted-foreground")

  return {
    maintainAspectRatio: false,
    layout: {
      padding: { left: 8, right: 8, top: 4, bottom: 4 }
    },
    interaction: {
      mode: "index",
      intersect: false
    },
    elements: {
      line: { borderWidth: 2 },
      point: { radius: 0, hoverRadius: 4, hitRadius: 12 }
    },
    plugins: {
      legend: {
        display: useCanvasLegend,
        position: "bottom",
        align: "start",
        labels: {
          usePointStyle: true,
          pointStyle: "line",
          padding: 16,
          boxWidth: 12,
          boxHeight: 8,
          color: mutedFg || fg,
          font: { size: 12, family: "ui-sans-serif, system-ui, sans-serif" }
        }
      },
      tooltip: {
        enabled: true,
        backgroundColor: card,
        titleColor: fg,
        bodyColor: muted || mutedFg || fg,
        borderColor: border,
        borderWidth: 1,
        padding: 12,
        cornerRadius: 8,
        displayColors: true,
        boxPadding: 6,
        titleMarginBottom: 8,
        bodySpacing: 6,
        titleFont: { size: 12, weight: "500", family: "ui-sans-serif, system-ui, sans-serif" },
        bodyFont: { size: 12, family: "ui-sans-serif, system-ui, sans-serif" },
        footerFont: { size: 11, family: "ui-sans-serif, system-ui, sans-serif" }
      }
    },
    scales: {
      x: {
        border: { display: false },
        grid: { display: false },
        ticks: {
          maxRotation: 0,
          minRotation: 0,
          autoSkip: true,
          autoSkipPadding: 8,
          padding: 8,
          color: mutedFg || fg,
          font: { size: 12, family: "ui-sans-serif, system-ui, sans-serif" }
        }
      },
      y: {
        border: { display: false },
        beginAtZero: true,
        grid: {
          display: true,
          color: gridMuted,
          drawTicks: false,
          lineWidth: 1
        },
        ticks: {
          color: mutedFg || fg,
          font: { size: 12, family: "ui-sans-serif, system-ui, sans-serif" },
          padding: 8
        }
      }
    }
  }
}

export default class extends Controller {
  static targets = ["canvas", "legend"]
  static values = {
    config: String,
    preset: { type: String, default: "" },
    legendAriaLabel: { type: String, default: "" }
  }

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

    const { type, data, options: configOptions } = config
    if (!type || !data) return

    const chartCanvas = this.resolveCanvasElement()
    if (!chartCanvas || chartCanvas.tagName !== "CANVAS") return

    this._useHtmlLegend =
      this.presetValue === "shadcn-line" &&
      type === "line" &&
      this.hasLegendTarget

    const defaultOptions = {
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

    let options = deepMerge({}, defaultOptions)
    if (this.presetValue === "shadcn-line" && type === "line") {
      options = deepMerge(options, shadcnLinePreset(!this._useHtmlLegend))
    }
    if (configOptions) {
      options = deepMerge(options, configOptions)
    }
    if (this._useHtmlLegend) {
      options = deepMerge(options, {
        plugins: {
          legend: { display: false }
        }
      })
    }

    if (this.presetValue === "shadcn-line" && type === "line") {
      options.onResize = (chart) => {
        applyShadcnLineResponsive(chart, !this._useHtmlLegend)
      }
    }

    this.chart = new Chart(chartCanvas, {
      type,
      data,
      options
    })

    if (this.presetValue === "shadcn-line" && type === "line") {
      applyShadcnLineResponsive(this.chart, !this._useHtmlLegend)
      this.chart.update()
      this._resizeAnimationFrame = null
      this._onWindowResize = () => {
        if (this._resizeAnimationFrame !== null) return
        this._resizeAnimationFrame = window.requestAnimationFrame(() => {
          this._resizeAnimationFrame = null
          if (!this.chart) return
          applyShadcnLineResponsive(this.chart, !this._useHtmlLegend)
          this.chart.update("none")
        })
      }
      window.addEventListener("resize", this._onWindowResize)
    }

    if (this._useHtmlLegend) {
      this.buildHtmlLegend()
    }
  }

  resolveCanvasElement() {
    if (this.hasCanvasTarget) return this.canvasTarget
    return this.element
  }

  buildHtmlLegend() {
    if (!this.hasLegendTarget || !this.chart) return

    const container = this.legendTarget
    container.innerHTML = ""
    if (this.legendAriaLabelValue) {
      container.setAttribute("aria-label", this.legendAriaLabelValue)
    }
    container.setAttribute("role", "group")

    const chart = this.chart
    chart.data.datasets.forEach((ds, i) => {
      const color =
        typeof ds.borderColor === "string"
          ? ds.borderColor
          : Array.isArray(ds.borderColor)
            ? ds.borderColor[0]
            : "#737373"

      const btn = document.createElement("button")
      btn.type = "button"
      btn.dataset.datasetIndex = String(i)
      btn.className =
        "flex w-full min-h-11 items-center gap-2.5 rounded-lg border border-border bg-background px-3 py-2.5 text-left text-sm font-medium text-card-foreground shadow-sm transition-colors hover:bg-muted/60 active:bg-muted sm:w-auto sm:max-w-[14rem]"
      btn.setAttribute("aria-pressed", chart.isDatasetVisible(i) ? "true" : "false")

      const swatch = document.createElement("span")
      swatch.className = "h-1 w-9 shrink-0 rounded-full"
      swatch.style.backgroundColor = color
      swatch.setAttribute("aria-hidden", "true")

      const label = document.createElement("span")
      label.className = "min-w-0 flex-1 truncate"
      label.textContent = ds.label != null ? String(ds.label) : `Series ${i + 1}`

      btn.append(swatch, label)
      btn.addEventListener("click", () => this.toggleDataset(i))

      container.appendChild(btn)
    })

    this.syncHtmlLegendStates()
  }

  toggleDataset(index) {
    if (!this.chart) return
    const next = !this.chart.isDatasetVisible(index)
    this.chart.setDatasetVisibility(index, next)
    this.chart.update()
    this.syncHtmlLegendStates()
  }

  syncHtmlLegendStates() {
    if (!this.hasLegendTarget || !this.chart) return
    this.legendTarget.querySelectorAll("button[data-dataset-index]").forEach((btn) => {
      const i = Number.parseInt(btn.dataset.datasetIndex, 10)
      if (Number.isNaN(i)) return
      const visible = this.chart.isDatasetVisible(i)
      btn.setAttribute("aria-pressed", visible ? "true" : "false")
      btn.classList.toggle("opacity-45", !visible)
      btn.classList.toggle("grayscale", !visible)
    })
  }

  disconnect() {
    if (this._onWindowResize) {
      window.removeEventListener("resize", this._onWindowResize)
      this._onWindowResize = null
    }
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
    if (this.hasLegendTarget) {
      this.legendTarget.innerHTML = ""
    }
  }
}
