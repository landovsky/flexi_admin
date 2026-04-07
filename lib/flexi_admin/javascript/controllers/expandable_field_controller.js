import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.resize();
  }

  resize() {
    this.element.style.height = "auto";
    const styles = getComputedStyle(this.element);
    const minHeight = this._minimumHeight(styles);

    this.element.style.height =
      Math.max(this.element.scrollHeight, minHeight) + "px";
  }

  _minimumHeight(styles) {
    const explicitMinHeight = parseFloat(styles.minHeight);
    if (!Number.isNaN(explicitMinHeight) && explicitMinHeight > 0) {
      return explicitMinHeight;
    }

    const lineHeight = parseFloat(styles.lineHeight) || 24;
    const paddingTop = parseFloat(styles.paddingTop) || 0;
    const paddingBottom = parseFloat(styles.paddingBottom) || 0;
    const borderTop = parseFloat(styles.borderTopWidth) || 0;
    const borderBottom = parseFloat(styles.borderBottomWidth) || 0;

    return lineHeight + paddingTop + paddingBottom + borderTop + borderBottom;
  }
}
