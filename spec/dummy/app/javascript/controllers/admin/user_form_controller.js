import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin--user-form"
export default class extends Controller {
  static targets = ["form", "field"]
  static values = {
    url: String,
    autoSave: { type: Boolean, default: false }
  }

  connect() {
    console.log("User form controller connected", {
      autoSave: this.autoSaveValue,
      url: this.urlValue
    })
  }

  // Handle form field changes
  change(event) {
    console.log("Field changed:", event.target.name, event.target.value)

    if (this.autoSaveValue) {
      this.autoSave(event)
    }

    // Update URL with new value
    this.updateURL(event.target.name, event.target.value)
  }

  // Auto-save on field change
  autoSave(event) {
    const field = event.target
    const formData = new FormData()
    formData.append(field.name, field.value)

    // Add Rails authenticity token
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (token) {
      formData.append('authenticity_token', token)
    }

    // Fetch turbo stream response
    fetch(this.urlValue || this.formTarget.action, {
      method: 'PATCH',
      body: formData,
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Auto-save error:', error)
    })
  }

  // Handle form submission
  submit(event) {
    event.preventDefault()

    const formData = new FormData(this.formTarget)

    fetch(this.formTarget.action, {
      method: this.formTarget.method || 'POST',
      body: formData,
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => {
      if (response.ok) {
        return response.text()
      } else {
        throw new Error('Form submission failed')
      }
    })
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Form submission error:', error)
    })
  }

  // Update browser URL with form state
  updateURL(name, value) {
    const url = new URL(window.location.href)
    url.searchParams.set(name, value)
    history.pushState({}, "", url.toString())
  }

  // Validate form before submission
  validate() {
    const requiredFields = this.formTarget.querySelectorAll('[required]')
    let isValid = true

    requiredFields.forEach(field => {
      if (!field.value.trim()) {
        isValid = false
        field.classList.add('is-invalid')
      } else {
        field.classList.remove('is-invalid')
      }
    })

    return isValid
  }

  // Reset form to initial state
  reset(event) {
    if (event) {
      event.preventDefault()
    }

    this.formTarget.reset()

    // Remove validation states
    this.formTarget.querySelectorAll('.is-invalid').forEach(field => {
      field.classList.remove('is-invalid')
    })
  }
}
