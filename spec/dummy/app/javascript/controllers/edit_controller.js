import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit"
export default class extends Controller {
  static targets = ["field", "button"]

  connect() {
    console.log("Edit controller connected")
    this.isEditMode = false
  }

  toggle(event) {
    event.preventDefault()

    // Find all form inputs within this controller's element
    const inputs = this.element.querySelectorAll('input[type="text"], input[type="email"], input[type="tel"], select, textarea')

    inputs.forEach(input => {
      if (input.disabled) {
        input.disabled = false
        input.classList.add('editable')
      } else {
        input.disabled = true
        input.classList.remove('editable')
      }
    })

    // Update button text
    const button = event.currentTarget
    this.isEditMode = !this.isEditMode

    if (this.isEditMode) {
      button.textContent = 'Cancel'
      button.classList.remove('btn-primary')
      button.classList.add('btn-secondary')
    } else {
      button.textContent = 'Edit'
      button.classList.remove('btn-secondary')
      button.classList.add('btn-primary')
    }
  }
}
