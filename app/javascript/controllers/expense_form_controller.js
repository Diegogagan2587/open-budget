import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dateField", "incomeEventSelect", "incomeEventContainer", "message"]
  static values = {
    incomeEvents: Array
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
    this.updateIncomeEventOptionsWithOtherMonths(sameMonthEvents, otherMonthEvents, selectedDate)
    
    // Show helpful message
    if (sameMonthEvents.length === 0 && otherMonthEvents.length > 0) {
      this.showMessage(`No income events found for ${selectedDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}. Showing events from other months below.`)
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
    
    // Store blank option text if it exists
    const blankOption = select.querySelector('option[value=""]')
    const blankOptionText = blankOption ? blankOption.textContent : "Ninguno (sin asignar)"
    
    // Clear all options
    select.innerHTML = ''
    
    // Add blank option first
    const blankOpt = document.createElement('option')
    blankOpt.value = ""
    blankOpt.textContent = blankOptionText
    select.appendChild(blankOpt)

    // Add filtered options
    events.forEach(event => {
      const option = document.createElement('option')
      option.value = event.id
      option.textContent = this.formatIncomeEventLabel(event)
      select.appendChild(option)
    })

    // Try to preserve the selected value if it's still in the filtered list
    const preservedValue = events.find(e => e.id.toString() === currentValue)
    if (preservedValue) {
      select.value = currentValue
    } else if (currentValue && events.length > 0) {
      // If current selection is not in filtered list, clear it
      select.value = ""
    }
  }

  updateIncomeEventOptionsWithOtherMonths(sameMonthEvents, otherMonthEvents, selectedDate) {
    if (!this.hasIncomeEventSelectTarget) return

    const select = this.incomeEventSelectTarget
    const currentValue = select.value
    
    const blankOptionText = "Ninguno (sin asignar)"
    
    // Clear all options
    select.innerHTML = ''
    
    // Add blank option first
    const blankOpt = document.createElement('option')
    blankOpt.value = ""
    blankOpt.textContent = blankOptionText
    select.appendChild(blankOpt)

    // Add same-month events first
    sameMonthEvents.forEach(event => {
      const option = document.createElement('option')
      option.value = event.id
      option.textContent = this.formatIncomeEventLabel(event)
      select.appendChild(option)
    })

    // Add separator and other months if needed
    if (otherMonthEvents && otherMonthEvents.length > 0) {
      if (sameMonthEvents.length > 0) {
        const separator = document.createElement('option')
        separator.disabled = true
        separator.textContent = '─── Other Months ───'
        select.appendChild(separator)
      }
      
      // Add other months' events (sorted by date, newest first)
      otherMonthEvents
        .sort((a, b) => new Date(b.expected_date) - new Date(a.expected_date))
        .forEach(event => {
          const option = document.createElement('option')
          option.value = event.id
          option.textContent = this.formatIncomeEventLabel(event)
          select.appendChild(option)
        })
    }

    // Preserve selected value if still available
    const allOptions = sameMonthEvents.concat(otherMonthEvents || [])
    const preservedValue = allOptions.find(e => e.id.toString() === currentValue)
    if (preservedValue) {
      select.value = currentValue
    } else if (currentValue) {
      select.value = ""
    }
  }

  formatIncomeEventLabel(event) {
    const date = new Date(event.expected_date)
    const formattedDate = date.toLocaleDateString('en-US', { 
      day: 'numeric', 
      month: 'short', 
      year: 'numeric' 
    })
    const amount = new Intl.NumberFormat('en-US', {
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
}
