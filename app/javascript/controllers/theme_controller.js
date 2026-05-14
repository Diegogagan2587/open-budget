import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "switch", "paletteSelect"]

  connect() {
    this.storageKey = "theme"
    this.paletteStorageKey = "theme_palette"
    this.palettePrefix = "palette-"
    this.legacyPaletteMap = {
      "ios-balanced": "executive-calm",
      "ios-ocean": "ocean-depth",
      "ios-forest": "forest-mint",
      "ios-sunset": "sunset-ember"
    }
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.boundSystemChange = this.handleSystemChange.bind(this)
    this.mediaQuery.addEventListener("change", this.boundSystemChange)

    this.syncPaletteFromServer()
    this.applyStoredOrSystemTheme()
    this.refreshLabel()
    this.refreshPaletteSelect()
  }

  disconnect() {
    this.mediaQuery.removeEventListener("change", this.boundSystemChange)
  }

  toggle() {
    const nextTheme = this.isDark() ? "light" : "dark"
    this.applyTheme(nextTheme)
    localStorage.setItem(this.storageKey, nextTheme)
    this.refreshLabel()
  }

  handleSystemChange() {
    if (localStorage.getItem(this.storageKey)) return
    this.applyStoredOrSystemTheme()
    this.refreshLabel()
  }

  applyStoredOrSystemTheme() {
    const stored = localStorage.getItem(this.storageKey)
    if (stored === "dark" || stored === "light") {
      this.applyTheme(stored)
      return
    }

    this.applyTheme(this.mediaQuery.matches ? "dark" : "light")
  }

  applyTheme(theme) {
    document.documentElement.classList.toggle("dark", theme === "dark")
  }

  changePalette(event) {
    const palette = event?.target?.value
    if (!palette) return
    this.applyPalette(palette)
    localStorage.setItem(this.paletteStorageKey, palette)

    if (event.target.dataset.autosave === "true") {
      event.target.form?.requestSubmit()
    }
  }

  syncPaletteFromServer() {
    const serverDefault = this.normalizePalette(document.documentElement.dataset.defaultPalette || "executive-calm")
    const stored = localStorage.getItem(this.paletteStorageKey)
    const palette = this.normalizePalette(stored) || serverDefault

    this.applyPalette(palette)
    localStorage.setItem(this.paletteStorageKey, palette)
  }

  applyPalette(palette) {
    const html = document.documentElement
    html.classList.forEach((cssClass) => {
      if (cssClass.startsWith(this.palettePrefix)) html.classList.remove(cssClass)
    })
    html.classList.add(`${this.palettePrefix}${palette}`)
  }

  isDark() {
    return document.documentElement.classList.contains("dark")
  }

  refreshLabel() {
    const dark = this.isDark()

    this.labelTargets.forEach((label) => {
      label.textContent = dark ? "Light mode" : "Dark mode"
    })

    this.switchTargets.forEach((switchControl) => {
      switchControl.setAttribute("aria-checked", String(dark))
      switchControl.dataset.state = dark ? "checked" : "unchecked"
      switchControl.setAttribute("aria-label", dark ? "Light mode" : "Dark mode")
    })
  }

  refreshPaletteSelect() {
    const htmlClass = Array.from(document.documentElement.classList).find((cssClass) => cssClass.startsWith(this.palettePrefix))
    if (!htmlClass) return
    const palette = htmlClass.replace(this.palettePrefix, "")
    this.paletteSelectTargets.forEach((select) => {
      select.value = palette
    })
  }

  normalizePalette(palette) {
    if (!palette) return null
    return this.legacyPaletteMap[palette] || palette
  }
}
