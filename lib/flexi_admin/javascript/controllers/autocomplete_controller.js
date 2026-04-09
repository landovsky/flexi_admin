import { Controller } from "@hotwired/stimulus";
import { markValid } from "../utils";

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static targets = [
    "input",
    "list",
    "clearIcon",
    "loadingIcon",
    "resourceId",
    "isDisabled",
  ];

  connect() {
    this._disableInput(this.inputTarget.dataset.autocompleteIsDisabled);
    this.timeout = null;
    this.blurTimeout = null;
    if (this.inputTarget.value && !this.inputTarget.disabled) {
      this._clearIcon("show");
    } else {
      this._clearIcon("hide");
    }
    this._loadingIcon("hide");
  }

  disconnect() {
    clearTimeout(this.timeout);
    clearTimeout(this.blurTimeout);
    this.hideResults();
  }

  keyup(event) {
    if (this.inputTarget.value.length > 0) {
      this.listTarget.classList.remove("d-none");
      this._clearIcon("show");
      markValid(event);
    } else {
      this.hideResults();
      this._clearIcon("hide");
      return;
    }

    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this._search(this.inputTarget.value);
    }, 300);
  }

  hideResults() {
    this.listTarget.classList.add("d-none");
  }

  onFocusOut(event) {
    // Delay hiding results to allow for click events on results
    this.blurTimeout = setTimeout(() => {
      this.hideResults();
    }, 200);
  }

  preventBlur(event) {
    // Prevent the blur event when clicking on a result
    event.preventDefault();
    clearTimeout(this.blurTimeout);
  }

  select(event) {
    this.resourceIdTarget.value =
      event.currentTarget.dataset.autocompleteResourceIdValue;
    this.inputTarget.value = event.currentTarget.innerText;
    this.inputTarget.dispatchEvent(new Event("input"));
    clearTimeout(this.blurTimeout);
    this.hideResults();
  }

  inputValue(event) {
    this.inputTarget.value = event.currentTarget.innerText;
    this.inputTarget.dispatchEvent(new Event("input"));
    this.hideResults();
  }

  clear() {
    this.inputTarget.value = "";
    this.resourceIdTarget.value = "";
    this.inputTarget.dispatchEvent(new Event("input"));
    this.hideResults();
    this._clearIcon("hide");
    this.inputTarget.focus();
  }

  _loadingIcon(string) {
    if (string === "show") {
      this.loadingIconTarget.classList.remove("d-none");
    } else {
      this.loadingIconTarget.classList.add("d-none");
    }
  }

  _clearIcon(string) {
    if (string === "show") {
      this.clearIconTarget.classList.remove("d-none");
    } else {
      this.clearIconTarget.classList.add("d-none");
    }
  }

  _disableInput(string) {
    if (string === "true") {
      this.inputTarget.disabled = true;
    } else {
      this.inputTarget.disabled = false;
    }
  }

  async _search(string) {
    const path = this.inputTarget.dataset.autocompleteSearchPath;
    const url = new URL(path, window.location.origin);
    url.searchParams.set("q", string);

    try {
      this.loadingIconTarget.classList.remove("d-none"); // Show loading icon
      const response = await fetch(url.toString(), {
        headers: {
          Accept: "text/html",
        },
      });

      if (response.ok) {
        const html = await response.text();
        this._clearIcon("show");
        this.listTarget.innerHTML = html; // Set the results as inner HTML
      } else {
        console.error("Error fetching search results:", response.statusText);
      }
    } catch (error) {
      console.error("Network error:", error);
    } finally {
      this.loadingIconTarget.classList.add("d-none"); // Hide loading icon
    }
  }
}
