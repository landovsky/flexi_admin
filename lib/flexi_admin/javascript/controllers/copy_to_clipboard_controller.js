import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  copy() {
    const input = this.element.querySelector("input, textarea")
    if (!input) return

    navigator.clipboard.writeText(input.value).then(() => {
      const icon = this.element.querySelector(".copy-field-btn i")
      if (!icon) return

      icon.classList.replace("bi-clipboard", "bi-check")
      setTimeout(() => icon.classList.replace("bi-check", "bi-clipboard"), 1500)
    })
  }
}
