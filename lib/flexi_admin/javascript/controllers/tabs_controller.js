import { Controller } from "@hotwired/stimulus";

// Keeps the open tab of a TabsComponent in the URL hash (#<key>), so a reload or a
// shared link reopens the same tab instead of falling back to the first one.
//
// Connects to data-controller="tabs". Each tab button carries
// data-tabs-key-param="<key>" and data-action="shown.bs.tab->tabs#remember".
export default class extends Controller {
  connect() {
    const key = decodeURIComponent(window.location.hash.replace("#", ""));
    if (!key) return;

    const button = Array.from(this.element.querySelectorAll("[data-tabs-key-param]")).find(
      (candidate) => candidate.dataset.tabsKeyParam === key
    );
    // Clicking goes through Bootstrap's own data-api, so the controller needs no
    // reference to the `bootstrap` global.
    if (button && !button.classList.contains("active")) button.click();
  }

  remember({ params: { key } }) {
    history.replaceState(history.state, "", `#${key}`);
  }
}
