import { Controller } from "@hotwired/stimulus";
import { fetchTurboContent } from "../utils";

// Connects to data-controller="bulk-action"
export default class extends Controller {
  static values = {
    scope: String,
  };

  static targets = ["counter", "defaultText", "selectionText"];

  connect() {
    this._loadFromStorage();

    // Bind the handler so we can properly remove it in disconnect
    this._boundModalOpened = this._modalOpened.bind(this);
    document.addEventListener("bulk-action-modal-opened", this._boundModalOpened);

    // Track shiftKey from click events (change events don't carry modifier keys)
    this._boundTrackShift = (e) => { this._shiftDown = e.shiftKey; };
    this.element.addEventListener("click", this._boundTrackShift, true);

    // Restore checkbox states based on stored selections
    this._restoreCheckboxStates();
    this._updateSelectionUI();
  }

  disconnect() {
    document.removeEventListener("bulk-action-modal-opened", this._boundModalOpened);
    this.element.removeEventListener("click", this._boundTrackShift, true);
  }

  async requestModal(event) {
    const url = await event.target.dataset.urlWithId;
    fetchTurboContent(event, url);
  }

  submitForm(event) {
    event.preventDefault();

    const modal = this._withModal();
    const form = modal.querySelector("form");
    form.requestSubmit();
    this._unselectAll();
  }

  toggle(event) {
    const checkbox = event.target;
    const checkboxes = this._allCheckboxes();

    if (this._shiftDown && this._lastClickedCheckbox) {
      const currentIndex = checkboxes.indexOf(checkbox);
      const lastIndex = checkboxes.indexOf(this._lastClickedCheckbox);

      if (currentIndex !== -1 && lastIndex !== -1) {
        const start = Math.min(currentIndex, lastIndex);
        const end = Math.max(currentIndex, lastIndex);

        for (let i = start; i <= end; i++) {
          checkboxes[i].checked = true;
          if (!this.selectedIds.includes(checkboxes[i].value)) {
            this.selectedIds.push(checkboxes[i].value);
          }
        }
      }
    } else {
      const id = checkbox.value;
      if (checkbox.checked) {
        this.selectedIds.push(id);
      } else {
        this.selectedIds = this.selectedIds.filter(
          (selectedId) => selectedId !== id
        );
      }
    }

    this._lastClickedCheckbox = checkbox;

    if (this.selectedIds.length > 0) {
      this._enableActions();
    } else {
      this._disableActions();
    }

    this._persist();
    this._saveToStorage();
    this._updateSelectionUI();
  }

  toggleAll(event) {
    if (event.target.checked) {
      this._selectAll();
    } else {
      this._unselectAll();
    }
  }

  navigateWithSelectedIds(event) {
    event.preventDefault();

    if (this.selectedIds.length === 0) {
      return;
    }

    const target = event.target || event.currentTarget;
    const baseUrl = target.dataset.baseUrl;
    const paramName = target.dataset.paramName || 'selected_ids[]';
    const params = new URLSearchParams();

    this.selectedIds.forEach(id => {
      params.append(paramName, id);
    });

    const url = `${baseUrl}?${params.toString()}`;
    window.Turbo.visit(url);
  }

  _modalOpened(event) {
    if (event.detail.scope !== this.scopeValue) {
      return;
    }

    const modal = this._withModal();

    // If selectedIds are provided in the event (from row action), use them
    // Otherwise, use the controller's selectedIds (from bulk checkbox selection)
    const idsToUse = event.detail.selectedIds && event.detail.selectedIds.length > 0
      ? event.detail.selectedIds
      : this.selectedIds;

    this._populateCountElements(modal, idsToUse.length);
    this._populateIds(modal, idsToUse);
    this._addProcessor(modal, event.detail.modalId);
    this._addScope(modal, event.detail.scope);
  }

  _populateCountElements(modal, count = null) {
    const countToUse = count !== null ? count : this.selectedIds.length;
    const countElements = modal.querySelectorAll("span.count");
    countElements.forEach((countElement) => {
      countElement.textContent = countToUse;
    });
  }

  _addScope(modal, scope) {
    const form = modal.querySelector("form");

    const existingInput = form.querySelector('input[name="fa_scope"]');
    if (existingInput) {
      existingInput.remove();
    }

    const hiddenInput = document.createElement("input");
    hiddenInput.type = "hidden";
    hiddenInput.name = "fa_scope";
    hiddenInput.value = scope;
    form.appendChild(hiddenInput);
  }

  _addProcessor(modal, processor) {
    const form = modal.querySelector("form");

    // Remove any existing processor input to prevent duplicates when called multiple times
    const existingProcessorInput = form.querySelector('input[name="processor"]');
    if (existingProcessorInput) {
      existingProcessorInput.remove();
    }

    const hiddenInput = document.createElement("input");
    hiddenInput.type = "hidden";
    hiddenInput.name = "processor";
    hiddenInput.value = processor;
    form.appendChild(hiddenInput);
  }

  _populateIds(modal, ids = null) {
    const idsToUse = ids !== null ? ids : this.selectedIds;
    const form = modal.querySelector("form");

    // Remove any existing ids input to prevent duplicates when called multiple times
    const existingIdsInput = form.querySelector('input[name="ids"]');
    if (existingIdsInput) {
      existingIdsInput.remove();
    }

    const hiddenInput = document.createElement("input");
    hiddenInput.type = "hidden";
    hiddenInput.name = "ids";
    hiddenInput.value = JSON.stringify(idsToUse);
    form.appendChild(hiddenInput);
  }

  _withModal() {
    return document.querySelector(`#modalx_${this.scopeValue}`);
  }

  _selectAll() {
    const checkboxes = this._allCheckboxes();

    this.selectedIds = checkboxes.map((checkbox) => checkbox.value);

    checkboxes.forEach((checkbox) => {
      checkbox.checked = true;
    });

    this._persist();
    this._saveToStorage();
    this._updateSelectionUI();
    this._enableActions();
  }

  _unselectAll() {
    this.selectedIds = [];
    this._lastClickedCheckbox = null;
    const checkboxes = this._allCheckboxes();
    checkboxes.forEach((checkbox) => {
      checkbox.checked = false;
    });

    const selectAllCheckbox = document.querySelector('#checkbox-all');
    if (selectAllCheckbox) selectAllCheckbox.checked = false;

    this._persist();
    this._saveToStorage();
    this._updateSelectionUI();
    this._disableActions();
  }

  _persist() {
    this.element.dataset.ids = JSON.stringify(this.selectedIds);
  }

  _enableActions() {
    document
      .querySelectorAll(".dropdown-item.bulk-action.selection-dependent")
      .forEach((item) => {
        item.classList.remove("disabled");
      });
  }

  _disableActions() {
    document
      .querySelectorAll(".dropdown-item.bulk-action.selection-dependent")
      .forEach((item) => {
        item.classList.add("disabled");
      });
  }

  clearSelection(event) {
    event.preventDefault();
    this._unselectAll();
  }

  _storageKey() {
    return `bulk_action_selection_${this.scopeValue}`;
  }

  _loadFromStorage() {
    const stored = sessionStorage.getItem(this._storageKey());
    if (stored) {
      try {
        this.selectedIds = JSON.parse(stored);
      } catch (e) {
        this.selectedIds = [];
      }
    } else {
      this.selectedIds = [];
    }
  }

  _saveToStorage() {
    sessionStorage.setItem(this._storageKey(), JSON.stringify(this.selectedIds));
  }

  _restoreCheckboxStates() {
    if (this.selectedIds.length === 0) {
      return;
    }

    const checkboxes = this._allCheckboxes();
    checkboxes.forEach((checkbox) => {
      if (this.selectedIds.includes(checkbox.value)) {
        checkbox.checked = true;
      }
    });

    if (this.selectedIds.length > 0) {
      this._enableActions();
    }
  }

  _allCheckboxes() {
    return Array.from(document.querySelectorAll(
      `.bulk-action-checkbox > input[name="${this.scopeValue}"]:not(#checkbox-all)`
    ));
  }

  _updateSelectionUI() {
    const count = this.selectedIds.length;

    // Update counter value
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = count;
    }

    // Toggle between default text and selection text
    if (this.hasDefaultTextTarget && this.hasSelectionTextTarget) {
      if (count > 0) {
        this.defaultTextTarget.style.display = 'none';
        this.selectionTextTarget.style.display = 'inline';
      } else {
        this.defaultTextTarget.style.display = 'inline';
        this.selectionTextTarget.style.display = 'none';
      }
    }
  }
}
