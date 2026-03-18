import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.resize();
  }

  resize() {
    this.element.style.height = "auto";
    const minHeight =
      parseFloat(getComputedStyle(this.element).lineHeight) || 36;
    this.element.style.height =
      Math.max(this.element.scrollHeight, minHeight) + "px";
  }
}
