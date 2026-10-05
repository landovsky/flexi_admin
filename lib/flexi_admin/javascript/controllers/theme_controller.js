import { Controller } from "@hotwired/stimulus";

// Cycles the color theme auto → light → dark (see ThemeToggleComponent).
// The actual switching and persistence live in the inline ThemeScriptComponent
// (window.FlexiAdminTheme), which must run before first paint.
//
// Connects to data-controller="theme".
const ORDER = ["auto", "light", "dark"];
const DISPLAY = {
  auto: { icon: "bi-circle-half", label: "Auto" },
  light: { icon: "bi-sun", label: "Light" },
  dark: { icon: "bi-moon-stars", label: "Dark" },
};

export default class extends Controller {
  static targets = ["icon", "label"];

  connect() {
    this.render();
  }

  cycle() {
    const theme = window.FlexiAdminTheme;
    if (!theme) return;

    const next = ORDER[(ORDER.indexOf(theme.preference()) + 1) % ORDER.length];
    theme.set(next);
    this.render();
  }

  render() {
    const pref = window.FlexiAdminTheme?.preference() || "auto";
    const { icon, label } = DISPLAY[pref] || DISPLAY.auto;

    if (this.hasIconTarget) this.iconTarget.className = `bi ${icon}`;
    if (this.hasLabelTarget) this.labelTarget.textContent = label;
    this.element.title = `Theme: ${label}`;
  }
}
