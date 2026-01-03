import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selection", "select", "info", "categorySelect", "descriptionField", "amountField", "amountHint", "notesField"]
  static values = {
    templates: Array
  }

  connect() {
    this.toggleSelection()
    
    if (this.hasSelectTarget && this.selectTarget.value) {
      const templateId = parseInt(this.selectTarget.value)
      const template = this.templatesValue.find(t => t.id === templateId)
      if (template) {
        this.updateFormFromTemplate(template)
      }
    }
  }

  toggle() {
    this.toggleSelection()
  }

  selectTemplate() {
    const templateId = parseInt(this.selectTarget.value)
    if (!templateId) {
      this.updateFormFromTemplate(null)
      return
    }

    const template = this.templatesValue.find(t => t.id === templateId)
    if (template) {
      this.updateFormFromTemplate(template)
    }
  }

  toggleSelection() {
    if (!this.hasSelectionTarget) return
    
    const useTemplateYes = this.element.querySelector('input[value="yes"]')
    const useTemplateNo = this.element.querySelector('input[value="no"]')
    
    if (!useTemplateYes || !useTemplateNo) return

    const useTemplate = useTemplateYes.checked
    
    if (useTemplate) {
      this.selectionTarget.style.display = ""
      this.selectionTarget.classList.remove("hidden")
      
      if (useTemplateYes.closest('label')) {
        useTemplateYes.closest('label').classList.add('border-indigo-500')
      }
      
      if (this.hasSelectTarget) {
        const select = this.selectTarget
        void select.offsetHeight
        if (select.value) {
          this.selectTemplate()
        }
      }
    } else {
      this.selectionTarget.style.display = "none"
      this.selectionTarget.classList.add("hidden")
      if (useTemplateNo.closest('label')) {
        useTemplateNo.closest('label').classList.add('border-indigo-500')
      }
      if (this.hasSelectTarget) {
        this.selectTarget.value = ""
      }
      this.updateFormFromTemplate(null)
    }
  }

  updateFormFromTemplate(template) {
    if (template) {
      if (this.hasCategorySelectTarget) {
        this.categorySelectTarget.value = template.category_id
      }
      if (this.hasDescriptionFieldTarget) {
        this.descriptionFieldTarget.value = template.description || ""
      }
      if (this.hasAmountFieldTarget) {
        this.amountFieldTarget.value = ""
        const remaining = template.total_amount - template.saved
        const suggested = remaining > 0 ? remaining : template.total_amount / 2
        this.amountFieldTarget.placeholder = suggested.toFixed(2)
        if (this.hasAmountHintTarget) {
          this.amountHintTarget.textContent = `Suggested: ${suggested.toFixed(2)} (${remaining > 0 ? 'remaining amount' : 'split amount'})`
        }
      }
      if (this.hasNotesFieldTarget) {
        this.notesFieldTarget.value = template.notes || ""
      }
      
      if (this.hasInfoTarget) {
        const remaining = template.total_amount - template.saved
        const progress = template.total_amount > 0 ? (template.saved / template.total_amount) * 100 : 0
        
        this.infoTarget.innerHTML = `
          <div class="space-y-2">
            <h4 class="font-medium text-gray-900">${template.description || 'Template'}</h4>
            <div class="grid grid-cols-3 gap-4 text-sm">
              <div>
                <p class="text-gray-600">Total</p>
                <p class="font-semibold text-gray-900">$${template.total_amount.toFixed(2)}</p>
              </div>
              <div>
                <p class="text-gray-600">Saved</p>
                <p class="font-semibold text-green-600">$${template.saved.toFixed(2)}</p>
              </div>
              <div>
                <p class="text-gray-600">Remaining</p>
                <p class="font-semibold text-indigo-600">$${remaining.toFixed(2)}</p>
              </div>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2 mt-2">
              <div class="bg-indigo-600 h-2 rounded-full transition-all duration-300" style="width: ${Math.min(progress, 100)}%"></div>
            </div>
          </div>
        `
      }
    } else {
      if (this.hasAmountFieldTarget) {
        this.amountFieldTarget.placeholder = "0.00"
        if (this.hasAmountHintTarget) {
          this.amountHintTarget.textContent = ""
        }
      }
      if (this.hasInfoTarget) {
        this.infoTarget.innerHTML = ""
      }
    }
  }
}
