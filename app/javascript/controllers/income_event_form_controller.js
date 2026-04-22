import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "incomeTypeSelect",
    "loanFields",
    "expectedAmountField",
    "loanAmountField",
    "interestRateField",
    "numberOfPaymentsField",
    "paymentFrequencyField",
    "paymentAmountField",
    "interestHint"
  ]

  connect() {
    this.syncing = false
    this.lastEdited = null
    this.userEditedInterest = this.hasInterestRateFieldTarget && this.interestRateFieldTarget.value.trim() !== ""
    this.toggleLoanFields()
    this.syncFromCurrentState()
  }

  toggleLoanFields() {
    if (!this.hasIncomeTypeSelectTarget || !this.hasLoanFieldsTarget) return

    const isLoan = this.incomeTypeSelectTarget.value === "loan"

    this.loanFieldsTarget.classList.toggle("hidden", !isLoan)

    if (this.hasExpectedAmountFieldTarget) {
      this.expectedAmountFieldTarget.classList.toggle("hidden", isLoan)
    }

    if (!isLoan) {
      this.hideInterestHint()
      return
    }

    this.syncFromCurrentState()
  }

  onSharedTermsChanged() {
    if (this.syncing) return
    this.syncFromCurrentState()
  }

  onPaymentInput() {
    if (this.syncing) return
    this.lastEdited = "payment"
    this.syncFromPayment(true)
  }

  onInterestInput() {
    if (this.syncing) return
    if (!this.hasInterestRateFieldTarget) return

    const currentValue = this.interestRateFieldTarget.value.trim()
    this.userEditedInterest = currentValue !== ""
    this.lastEdited = "interest"

    if (this.userEditedInterest) {
      this.interestRateFieldTarget.dataset.estimated = "false"
      this.syncFromInterest()
    } else {
      this.syncFromCurrentState()
    }
  }

  syncFromCurrentState() {
    if (!this.isLoanSelected()) return

    if (this.lastEdited === "interest") {
      if (!this.syncFromInterest()) this.syncFromPayment()
      return
    }

    if (this.lastEdited === "payment") {
      if (!this.syncFromPayment(true)) this.syncFromInterest()
      return
    }

    const paymentValue = this.hasPaymentAmountFieldTarget ? this.paymentAmountFieldTarget.value.trim() : ""
    const interestValue = this.hasInterestRateFieldTarget ? this.interestRateFieldTarget.value.trim() : ""

    if (paymentValue !== "") {
      if (!this.syncFromPayment(true)) this.syncFromInterest()
      return
    }

    if (interestValue !== "") {
      this.syncFromInterest()
      return
    }

    this.hideInterestHint()
  }

  syncFromPayment(forceOverrideInterest = false) {
    if (!this.isLoanSelected()) return
    if (!this.hasLoanAmountFieldTarget || !this.hasNumberOfPaymentsFieldTarget || !this.hasPaymentAmountFieldTarget || !this.hasPaymentFrequencyFieldTarget) {
      return false
    }

    const principal = this.parseNumber(this.loanAmountFieldTarget.value)
    const numberOfPayments = this.parseInteger(this.numberOfPaymentsFieldTarget.value)
    const paymentAmount = this.parseNumber(this.paymentAmountFieldTarget.value)
    const paymentFrequency = this.paymentFrequencyFieldTarget.value

    if (!principal || !numberOfPayments || !paymentAmount || !paymentFrequency) {
      this.hideInterestHint()
      return false
    }

    if (paymentAmount * numberOfPayments < principal) {
      this.showInterestHint("Payment amount is too low for the selected number of payments", true)
      return false
    }

    const annualRate = this.inferAnnualRate(principal, paymentAmount, numberOfPayments, paymentFrequency)

    if (forceOverrideInterest || this.shouldAutofillInterest()) {
      this.userEditedInterest = false
      this.syncing = true
      this.interestRateFieldTarget.value = annualRate.toFixed(3)
      this.interestRateFieldTarget.dataset.estimated = "true"
      this.syncing = false
    }

    this.showInterestHint(`Estimated annual interest rate: ${annualRate.toFixed(3)}%`, false)
    return true
  }

  syncFromInterest() {
    if (!this.isLoanSelected()) return false
    if (!this.hasLoanAmountFieldTarget || !this.hasNumberOfPaymentsFieldTarget || !this.hasInterestRateFieldTarget || !this.hasPaymentFrequencyFieldTarget || !this.hasPaymentAmountFieldTarget) {
      return false
    }

    const principal = this.parseNumber(this.loanAmountFieldTarget.value)
    const numberOfPayments = this.parseInteger(this.numberOfPaymentsFieldTarget.value)
    const annualRate = this.parseNonNegativeNumber(this.interestRateFieldTarget.value)
    const paymentFrequency = this.paymentFrequencyFieldTarget.value

    if (!principal || !numberOfPayments || annualRate === null || !paymentFrequency) {
      this.hideInterestHint()
      return false
    }

    const paymentAmount = this.computePaymentAmount(principal, annualRate, numberOfPayments, paymentFrequency)

    this.syncing = true
    this.paymentAmountFieldTarget.value = paymentAmount.toFixed(2)
    this.syncing = false

    this.showInterestHint(`Payment amount updated from annual interest rate: ${annualRate.toFixed(3)}%`, false)
    return true
  }

  shouldAutofillInterest() {
    if (!this.hasInterestRateFieldTarget) return false

    const field = this.interestRateFieldTarget
    const isEstimated = field.dataset.estimated === "true"
    return !this.userEditedInterest || isEstimated || field.value.trim() === ""
  }

  inferAnnualRate(principal, paymentAmount, numberOfPayments, paymentFrequency) {
    const periodsPerYear = this.periodsPerYear(paymentFrequency)

    if (paymentAmount * numberOfPayments <= principal) {
      return 0
    }

    const periodicRate = this.solvePeriodicRate(principal, paymentAmount, numberOfPayments)
    return periodicRate * periodsPerYear * 100
  }

  computePaymentAmount(principal, annualRate, numberOfPayments, paymentFrequency) {
    const periodsPerYear = this.periodsPerYear(paymentFrequency)
    const periodicRate = (annualRate / 100) / periodsPerYear

    if (periodicRate === 0) {
      return principal / numberOfPayments
    }

    const numerator = principal * periodicRate
    const denominator = 1 - Math.pow(1 + periodicRate, -numberOfPayments)
    return numerator / denominator
  }

  solvePeriodicRate(principal, paymentAmount, periods) {
    let low = 0.0
    let high = 1.0

    while (this.paymentForRate(principal, high, periods) < paymentAmount) {
      high *= 2
      if (high > 100) break
    }

    for (let i = 0; i < 80; i += 1) {
      const mid = (low + high) / 2.0
      const computedPayment = this.paymentForRate(principal, mid, periods)

      if (computedPayment < paymentAmount) {
        low = mid
      } else {
        high = mid
      }
    }

    return (low + high) / 2.0
  }

  paymentForRate(principal, rate, periods) {
    if (rate === 0) return principal / periods

    const numerator = principal * rate
    const denominator = 1 - Math.pow(1 + rate, -periods)
    return numerator / denominator
  }

  periodsPerYear(frequency) {
    if (frequency === "weekly") return 52.0
    if (frequency === "biweekly") return 26.0
    if (frequency === "quincenal") return 365.0 / 15.0
    return 12.0
  }

  parseNumber(value) {
    const parsed = parseFloat(value)
    return Number.isFinite(parsed) && parsed > 0 ? parsed : null
  }

  parseNonNegativeNumber(value) {
    const parsed = parseFloat(value)
    return Number.isFinite(parsed) && parsed >= 0 ? parsed : null
  }

  parseInteger(value) {
    const parsed = parseInt(value, 10)
    return Number.isInteger(parsed) && parsed > 0 ? parsed : null
  }

  isLoanSelected() {
    return this.hasIncomeTypeSelectTarget && this.incomeTypeSelectTarget.value === "loan"
  }

  showInterestHint(message, isError) {
    if (!this.hasInterestHintTarget) return

    this.interestHintTarget.textContent = message
    this.interestHintTarget.classList.remove("hidden", "text-gray-500", "text-red-600", "text-emerald-600")
    this.interestHintTarget.classList.add(isError ? "text-red-600" : "text-emerald-600")
  }

  hideInterestHint() {
    if (!this.hasInterestHintTarget) return

    this.interestHintTarget.classList.add("hidden")
  }
}