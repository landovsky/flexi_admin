import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    container: String,
    templateSelector: String
  }

  add() {
    const container = document.querySelector(this.containerValue)
    if (!container) return

    const templates = container.querySelectorAll(this.templateSelectorValue)
    if (templates.length === 0) return

    const lastTemplate = templates[templates.length - 1]
    const clone = lastTemplate.cloneNode(true)

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
  }
}
