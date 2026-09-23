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

    localStorage.setItem(this._storageKey(), newPerPage);
    fetchTurboContent(event, path);
  }

  _restorePerPage() {
    if (!this.hasPerPageSelectTarget) return;

    const savedPerPage = localStorage.getItem(this._storageKey());
    if (!savedPerPage || savedPerPage === this.perPageSelectTarget.value) return;

    const pathTemplate = this.perPageSelectTarget.dataset.perPagePath;
    const path = pathTemplate.replace("__PER_PAGE__", savedPerPage);

    loadTurboContent(path);
  }

  _storageKey() {
    return `pagination_per_page:${this.scopeValue}`;
  }
}
