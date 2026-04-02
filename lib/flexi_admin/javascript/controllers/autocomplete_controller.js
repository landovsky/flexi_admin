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
    this.highlightIndex = -1;

    // Read enhanced configuration from data attributes.
    // All options default to values that preserve the original search-mode
    // behaviour when the attributes are absent (i.e. for existing components
    // that pre-date these options).
    this.isSelectMode =
      this.inputTarget.dataset.autocompleteMode === "select";
    this.preloadCount =
      parseInt(this.inputTarget.dataset.autocompletePreloadCount) || 10;
    this.resultLimit =
      parseInt(this.inputTarget.dataset.autocompleteResultLimit) || 100;

    // Use nullish coalescing so that min_chars: 0 is honoured correctly.
    const minCharsAttr = this.inputTarget.dataset.autocompleteMinChars;
    this.minChars =
      minCharsAttr !== undefined ? parseInt(minCharsAttr) : 1;

    this.debounceMs =
      parseInt(this.inputTarget.dataset.autocompleteDebounceMs) || 200;

    // Default false so that existing components (no attribute) stay unchanged.
    this.highlightMatchesEnabled =
      this.inputTarget.dataset.autocompleteHighlightMatches === "true";
    this.showPreloadLabel =
      this.inputTarget.dataset.autocompleteShowPreloadLabel === "true";

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

  // ---------------------------------------------------------------------------
  // Focus — select mode only: fire an immediate preload fetch on focus.
  // ---------------------------------------------------------------------------

  onFocus(event) {
    if (!this.isSelectMode) return;
    if (this.inputTarget.value.length === 0) {
      this._search("", true);
    }
  }

  // ---------------------------------------------------------------------------
  // Keyup — debounced search, respects min_chars threshold.
  // ---------------------------------------------------------------------------

  keyup(event) {
    if (
      this.isSelectMode &&
      ["ArrowDown", "ArrowUp", "Enter", "Escape"].includes(event.key)
    ) {
      return;
    }

    const value = this.inputTarget.value;

    if (value.length === 0) {
      this._clearIcon("hide");
      if (this.isSelectMode) {
        // In select mode, clearing the input re-shows the preloaded list.
        this._search("", true);
      } else {
        this.hideResults();
      }
      return;
    }

    this._clearIcon("show");
    markValid(event);

    // Don't fire yet if the user hasn't typed enough characters.
    if (value.length < this.minChars) return;

    // Keep the dropdown visible with its current contents while the debounce
    // timer is running (same behaviour as the original controller).
    this.listTarget.classList.remove("d-none");
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this._search(value, false);
    }, this.debounceMs);
  }

  // ---------------------------------------------------------------------------
  // Keydown — keyboard navigation for select mode (arrows, enter, escape).
  // Search mode is unaffected: the method returns immediately.
  // ---------------------------------------------------------------------------

  keydown(event) {
    if (!this.isSelectMode) return;

    const items = this._getItems();

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        if (!items.length) return;
        this.highlightIndex = Math.min(
          this.highlightIndex + 1,
          items.length - 1
        );
        this._updateHighlight(items);
        break;

      case "ArrowUp":
        event.preventDefault();
        if (!items.length) return;
        this.highlightIndex = Math.max(this.highlightIndex - 1, 0);
        this._updateHighlight(items);
        break;

      case "Enter":
        event.preventDefault();
        if (this.highlightIndex >= 0 && items[this.highlightIndex]) {
          items[this.highlightIndex].click();
        }
        break;

      case "Escape":
        this.hideResults();
        this.highlightIndex = -1;
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Results visibility
  // ---------------------------------------------------------------------------

  hideResults() {
    this.listTarget.classList.add("d-none");
    this.highlightIndex = -1;
  }

  onFocusOut(event) {
    // Delay hiding so that click events on result items fire first.
    this.blurTimeout = setTimeout(() => {
      this.hideResults();
    }, 200);
  }

  preventBlur(event) {
    // Cancel the blur-hide timer when the user mousedowns inside the dropdown.
    event.preventDefault();
    clearTimeout(this.blurTimeout);
  }

  // ---------------------------------------------------------------------------
  // Selection handlers
  // ---------------------------------------------------------------------------

  select(event) {
    this.resourceIdTarget.value =
      event.currentTarget.dataset.autocompleteResourceIdValue;
    // innerText strips <mark> tags automatically, giving the plain display value.
    this.inputTarget.value = event.currentTarget.innerText.trim();
    this.inputTarget.dispatchEvent(new Event("input"));
    // Emit a custom event so consuming applications can react to selection.
    this.inputTarget.dispatchEvent(
      new CustomEvent("autocomplete:select", {
        bubbles: true,
        detail: {
          value: this.inputTarget.value,
          id: this.resourceIdTarget.value,
        },
      })
    );
    clearTimeout(this.blurTimeout);
    this.hideResults();
  }

  inputValue(event) {
    this.inputTarget.value = event.currentTarget.innerText.trim();
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

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  // Returns selectable result items, excluding section labels and hint rows.
  _getItems() {
    return Array.from(
      this.listTarget.querySelectorAll(
        "li:not(.autocomplete-section-label):not(.autocomplete-hint)"
      )
    );
  }

  // Applies the .autocomplete-highlighted class to the item at highlightIndex
  // and scrolls it into view.
  _updateHighlight(items) {
    items.forEach((item, index) => {
      item.classList.toggle(
        "autocomplete-highlighted",
        index === this.highlightIndex
      );
    });
    const current = items[this.highlightIndex];
    if (current) current.scrollIntoView({ block: "nearest" });
  }

  // Binds mouseover on result items so that hovering updates highlightIndex,
  // keeping keyboard and mouse highlight in sync. Called after each innerHTML
  // update — old listeners are discarded with the replaced DOM nodes.
  _bindMouseover() {
    const items = this._getItems();
    items.forEach((item, index) => {
      item.addEventListener("mouseover", () => {
        this.highlightIndex = index;
        this._updateHighlight(items);
      });
    });
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

  // Fetches results from the server and injects the returned HTML fragment.
  // When preloaded is true the request carries preload_count as the limit and
  // a preloaded=true flag so the server can render the correct section label.
  async _search(string, preloaded = false) {
    const path = this.inputTarget.dataset.autocompleteSearchPath;
    const url = new URL(path, window.location.origin);

    url.searchParams.set("q", string);
    url.searchParams.set("limit", preloaded ? this.preloadCount : this.resultLimit);
    url.searchParams.set(
      "highlight_matches",
      this.highlightMatchesEnabled ? "true" : "false"
    );
    url.searchParams.set(
      "show_preload_label",
      this.showPreloadLabel ? "true" : "false"
    );
    if (preloaded) url.searchParams.set("preloaded", "true");

    try {
      this._loadingIcon("show");
      const response = await fetch(url.toString(), {
        headers: { Accept: "text/html" },
      });

      if (response.ok) {
        const html = await response.text();
        this.listTarget.innerHTML = html;
        this.listTarget.classList.remove("d-none");
        this._clearIcon(string.length > 0 ? "show" : "hide");
        this.highlightIndex = -1;
        this._bindMouseover();
      } else {
        console.error(
          "Error fetching autocomplete results:",
          response.statusText
        );
      }
    } catch (error) {
      console.error("Network error:", error);
    } finally {
      this._loadingIcon("hide");
    }
  }
}
