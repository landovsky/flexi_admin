import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    container: String,
    templateSelector: { type: String, default: '.dynamic-rows > .form-row' }
  }

  connect() {
    // Initialize remove button visibility on page load
    const containerSelector = this.containerValue || this.element.dataset.addRowContainerValue
    if (containerSelector) {
      const container = document.querySelector(containerSelector)
      if (container) {
        this.updateRemoveButtonsVisibility(container)
      }
    }
  }

  add(event) {
    event.preventDefault()

    const button = event.target.closest('button')
    const containerSelector = button?.dataset.addRowContainerValue || this.containerValue
    const templateSelector = button?.dataset.addRowTemplateSelectorValue || this.templateSelectorValue

    // Store the container selector on the controller element for future use
    if (containerSelector && !this.containerValue) {
      this.element.dataset.addRowContainerValue = containerSelector
      this.containerValue = containerSelector
    }

    const container = document.querySelector(containerSelector)
    if (!container) {
      return
    }

    const templates = container.querySelectorAll(templateSelector)
    if (templates.length === 0) {
      return
    }

    const lastTemplate = templates[templates.length - 1]
    const clone = lastTemplate.cloneNode(true)

    // Mark the cloned row as removable
    clone.dataset.removable = 'true'

    const inputs = clone.querySelectorAll('input, select, textarea')
    inputs.forEach(input => {
      if (input.name) {
        input.name = input.name.replace(/\[(\d+)\]/g, (match, num) => {
          return `[${parseInt(num) + 1}]`
        })
      }
      // Clear values for new row
      if (input.tagName === 'SELECT') {
        input.selectedIndex = 0
      } else {
        input.value = ''
      }

      input.classList.remove('is-invalid')
      const feedback = input.closest('.field-wrapper')?.querySelector('.invalid-feedback')
      if (feedback) feedback.remove()
    })

    const labels = clone.querySelectorAll('label')
    labels.forEach(label => {
      if (label.textContent) {
        label.textContent = label.textContent.replace(/(\d+)/g, (match, num) => {
          return parseInt(num) + 1
        })
      }
    })

    container.appendChild(clone)
    this.updateRemoveButtonsVisibility(container)
  }

  remove(event) {
    event.preventDefault()

    const button = event.target.closest('button')
    const templateSelector = button?.dataset.addRowTemplateSelectorValue || this.templateSelectorValue || '.form-row'

    const row = event.target.closest(templateSelector)
    if (row) {
      const container = row.parentElement
      const rows = container.querySelectorAll(templateSelector)

      // Prevent removing the last row
      if (rows.length <= 1) {
        return
      }

      row.remove()
      this.updateRemoveButtonsVisibility(container)
    }
  }

  updateRemoveButtonsVisibility(container) {
    const templateSelector = this.templateSelectorValue || '.form-row'
    const rows = container.querySelectorAll(templateSelector)
    const removeButtons = container.querySelectorAll('button[data-action*="add-row#remove"]')

    const shouldShow = rows.length > 1
    removeButtons.forEach(button => {
      button.style.display = shouldShow ? '' : 'none'
    })
  }
}
