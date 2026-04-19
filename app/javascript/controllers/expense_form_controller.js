import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "dateField",
    "incomeEventSelect",
    "incomeEventContainer",
    "message",
    "accountTypeSelect",
    "assetAccountSection",
    "liabilityAccountSection"
  ]
  static values = {
    incomeEvents: Array,
    locale: String
  }

  connect() {
    // Store all income events for filtering
    this.allIncomeEvents = this.incomeEventsValue || []

    // If date is pre-filled, filter immediately
    if (this.hasDateFieldTarget && this.dateFieldTarget.value) {
      this.filterByDate()
    } else {
      // Show all income events initially
      this.updateIncomeEventOptions(this.allIncomeEvents)
    }

    this.toggleFinanceAccountFields()
  }

  filterByDate() {
    const dateValue = this.dateFieldTarget.value

    if (!dateValue) {
      // No date selected - show all income events
      this.updateIncomeEventOptions(this.allIncomeEvents)
      this.hideMessage()
      return
    }

    const selectedDate = new Date(dateValue)
    const selectedYear = selectedDate.getFullYear()
    const selectedMonth = selectedDate.getMonth()

    // Separate events: same month vs other months
    const sameMonthEvents = this.allIncomeEvents.filter(event => {
      const eventDate = new Date(event.expected_date)
      return eventDate.getFullYear() === selectedYear &&
             eventDate.getMonth() === selectedMonth
    })

    const otherMonthEvents = this.allIncomeEvents.filter(event => {
      const eventDate = new Date(event.expected_date)
      return !(eventDate.getFullYear() === selectedYear &&
               eventDate.getMonth() === selectedMonth)
    })

    // Show same-month events first, then other months
    this.updateIncomeEventOptionsWithOtherMonths(sameMonthEvents, otherMonthEvents)

    const loc = this.intlLocale()
    // Show helpful message
    if (sameMonthEvents.length === 0 && otherMonthEvents.length > 0) {
      this.showMessage(`No income events found for ${selectedDate.toLocaleDateString(loc, { month: 'long', year: 'numeric' })}. Showing events from other months below.`)
    } else if (sameMonthEvents.length === 0) {
      this.showMessage(`No income events found.`)
    } else {
      this.hideMessage()
    }
  }

  updateIncomeEventOptions(events) {
    if (!this.hasIncomeEventSelectTarget) return

    const select = this.incomeEventSelectTarget
    const currentValue = select.value

    const blankOption = select.querySelector('option[value=""]')
    const blankOptionText = blankOption ? blankOption.textContent : "Ninguno (sin asignar)"

    select.innerHTML = ''

    const blankOpt = document.createElement('option')
    blankOpt.value = ""
    blankOpt.textContent = blankOptionText
    select.appendChild(blankOpt)

    const grouped = this.groupEventsByMonthDescending(events)
    this.appendOptgroupsForMonths(select, grouped)

    const preservedValue = events.find(e => e.id.toString() === currentValue)
    if (preservedValue) {
      select.value = currentValue
    } else if (currentValue && events.length > 0) {
      select.value = ""
    }
  }

  updateIncomeEventOptionsWithOtherMonths(sameMonthEvents, otherMonthEvents) {
    if (!this.hasIncomeEventSelectTarget) return

    const select = this.incomeEventSelectTarget
    const currentValue = select.value

    const blankOptionText = "Ninguno (sin asignar)"

    select.innerHTML = ''

    const blankOpt = document.createElement('option')
    blankOpt.value = ""
    blankOpt.textContent = blankOptionText
    select.appendChild(blankOpt)

    sameMonthEvents.forEach(event => {
      const option = document.createElement('option')
      option.value = event.id
      option.textContent = this.formatIncomeEventLabel(event)
      select.appendChild(option)
    })

    if (otherMonthEvents && otherMonthEvents.length > 0) {
      if (sameMonthEvents.length > 0) {
        const separator = document.createElement('option')
        separator.disabled = true
        separator.textContent = '─── Other Months ───'
        select.appendChild(separator)
      }

      const grouped = this.groupEventsByMonthDescending(otherMonthEvents)
      this.appendOptgroupsForMonths(select, grouped)
    }

    const allOptions = sameMonthEvents.concat(otherMonthEvents || [])
    const preservedValue = allOptions.find(e => e.id.toString() === currentValue)
    if (preservedValue) {
      select.value = currentValue
    } else if (currentValue) {
      select.value = ""
    }
  }

  monthKeyFromExpectedDate(expectedDate) {
    const dt = new Date(expectedDate)
    const y = dt.getFullYear()
    const m = dt.getMonth() + 1
    return `${y}-${String(m).padStart(2, '0')}`
  }

  monthStartFromKey(key) {
    const [y, m] = key.split('-').map(Number)
    return new Date(y, m - 1, 1)
  }

  groupEventsByMonthDescending(events) {
    const map = new Map()
    events.forEach(event => {
      const key = this.monthKeyFromExpectedDate(event.expected_date)
      if (!map.has(key)) map.set(key, [])
      map.get(key).push(event)
    })
    const keys = [...map.keys()].sort((a, b) => b.localeCompare(a))
    return keys.map(key => {
      const monthEvents = map.get(key)
      monthEvents.sort((a, b) => new Date(b.expected_date) - new Date(a.expected_date))
      return { key, monthStart: this.monthStartFromKey(key), events: monthEvents }
    })
  }

  appendOptgroupsForMonths(select, grouped) {
    const loc = this.intlLocale()
    grouped.forEach(({ monthStart, events }) => {
      const og = document.createElement('optgroup')
      og.label = monthStart.toLocaleDateString(loc, { month: 'long', year: 'numeric' })
      events.forEach(event => {
        const option = document.createElement('option')
        option.value = event.id
        option.textContent = this.formatIncomeEventLabel(event)
        og.appendChild(option)
      })
      select.appendChild(og)
    })
  }

  intlLocale() {
    if (this.hasLocaleValue && this.localeValue && this.localeValue.trim() !== '') {
      return this.localeValue
    }
    return 'en-US'
  }

  formatIncomeEventLabel(event) {
    const date = new Date(event.expected_date)
    const loc = this.intlLocale()
    const formattedDate = date.toLocaleDateString(loc, {
      day: 'numeric',
      month: 'short',
      year: 'numeric'
    })
    const amount = new Intl.NumberFormat(loc, {
      style: 'currency',
      currency: 'USD'
    }).format(event.expected_amount)

    return `${event.description} - ${amount} (${formattedDate})`
  }

  showMessage(text) {
    if (!this.hasMessageTarget) return

    this.messageTarget.textContent = text
    this.messageTarget.classList.remove('hidden')
  }

  hideMessage() {
    if (!this.hasMessageTarget) return

    this.messageTarget.classList.add('hidden')
  }

  toggleFinanceAccountFields() {
    if (!this.hasAccountTypeSelectTarget) return

    const accountType = this.accountTypeSelectTarget.value || 'asset'
    const showAsset = accountType === 'asset'
    const showLiability = accountType === 'liability'

    if (this.hasAssetAccountSectionTarget) {
      this.assetAccountSectionTarget.classList.toggle('hidden', !showAsset)
    }

    if (this.hasLiabilityAccountSectionTarget) {
      this.liabilityAccountSectionTarget.classList.toggle('hidden', !showLiability)
    }

    if (showAsset && this.element.querySelector("#expense_financial_liability_id")) {
      this.element.querySelector("#expense_financial_liability_id").value = ""
    }

    if (showLiability && this.element.querySelector("#expense_financial_account_id")) {
      this.element.querySelector("#expense_financial_account_id").value = ""
    }
  }
}
