import { Controller } from "@hotwired/stimulus";
import { fetchTurboContent, loadTurboContent } from "../utils";

// Connects to data-controller="pagination"
export default class extends Controller {
  static targets = ["perPageSelect"];
  static values = { scope: String };

  connect() {
    this._restorePerPage();
  }

  paginate(event) {
    const path = event.target.dataset.resourcePath;

    fetchTurboContent(event, path);
  }

  changePerPage(event) {
    const newPerPage = event.target.value;
    const pathTemplate = event.target.dataset.perPagePath;
    const path = pathTemplate.replace("__PER_PAGE__", newPerPage);

    // Without a scope every list on the origin would share one key, so a choice
    // made on one section would leak into all the others — remember nothing
    // rather than remember it for the wrong list.
    if (this.scopeValue) localStorage.setItem(this._storageKey(), newPerPage);

    fetchTurboContent(event, path);
  }

  _restorePerPage() {
    if (!this.scopeValue || !this.hasPerPageSelectTarget) return;

    const select = this.perPageSelectTarget;
    const savedPerPage = localStorage.getItem(this._storageKey());
    if (!savedPerPage || savedPerPage === select.value) return;

    // Restoring converges only because the server echoes the requested per_page
    // back as the selected option, so the reconnected controller sees a match
    // and stops. A value the select no longer offers can never come back
    // selected — the browser falls back to the first option, connect() fires
    // again with the same mismatch, and we would fetch forever. Drop it.
    if (!Array.from(select.options).some((option) => option.value === savedPerPage)) {
      localStorage.removeItem(this._storageKey());
      return;
    }

    const pathTemplate = select.dataset.perPagePath;
    const path = pathTemplate.replace("__PER_PAGE__", savedPerPage);

    loadTurboContent(path);
  }

  _storageKey() {
    return `pagination_per_page:${this.scopeValue}`;
  }
}
