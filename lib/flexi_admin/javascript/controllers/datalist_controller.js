import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="autocomplete"
export default class extends Controller {
  static targets = ["input", "datalist", "clearIcon", "loadingIcon"];

  static values = {
    searchPath: String,
    isDisabled: Boolean,
    resourceId: String,
  };

  connect() {
    this._disableInput(this.isDisabledValue);
    this.timeout = null;
    if (this.inputTarget.value && !this.inputTarget.disabled) {
      this._clearIcon("show");
    } else {
      this._clearIcon("hide");
    }
    this._loadingIcon("hide");
  }

  disconnect() {
    clearTimeout(this.timeout);
    while (this.datalistTarget.firstChild) {
      this.datalistTarget.removeChild(this.datalistTarget.firstChild);
    }
  }

  keyup() {
    if (this.inputTarget.value.length > 0) {
      this._clearIcon("show");
    } else {
      this._clearIcon("hide");
      return;
    }

    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this._search(this.inputTarget.value);
    }, 300);
  }

  clear() {
    this.inputTarget.value = "";
    this.inputTarget.dispatchEvent(new Event("input"));
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
    const path = this.searchPathValue;
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
        this.datalistTarget.innerHTML = html; // Set the results as inner HTML
        this.inputTarget.dispatchEvent(new Event("input"));
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
