import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="role-selector"
export default class extends Controller {
  static targets = ["button"]

  connect() {
    console.log("Role selector controller connected")
  }

  select(event) {
    event.preventDefault()

    const button = event.currentTarget

    // Remove active class from all buttons in this selector
    this.buttonTargets.forEach(btn => {
      btn.classList.remove('active')
    })

    // Add active class to clicked button
    button.classList.add('active')

    // Optionally trigger a form submit or update
    const value = button.dataset.role || button.dataset.type
    console.log("Selected:", value)

    // Could trigger auto-save here if form controller is present
    const formController = this.application.getControllerForElementAndIdentifier(
      this.element.closest('[data-controller*="admin--user-form"]'),
      "admin--user-form"
    )

    if (formController && formController.autoSaveValue) {
      // Trigger auto-save
      const fieldName = button.dataset.role ? 'user[role]' : 'user[user_type]'
      const hiddenInput = this.element.querySelector('input[type="hidden"]') || this.createHiddenInput(fieldName)
      hiddenInput.value = value

      // Trigger change event for form controller
      hiddenInput.dispatchEvent(new Event('change', { bubbles: true }))
    }
  }

  createHiddenInput(name) {
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = name
    this.element.appendChild(input)
    return input
  }
}
