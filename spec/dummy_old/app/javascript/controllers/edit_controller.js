import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field"]

  toggle(event) {
    event.preventDefault()

    // Find all disabled inputs in the form
    const inputs = document.querySelectorAll('input[type="text"], input[type="email"]')

    inputs.forEach(input => {
      if (input.disabled) {
        input.disabled = false
        input.classList.add('editable')
      } else {
        input.disabled = true
        input.classList.remove('editable')
      }
    })
  }
}
