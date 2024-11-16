import { Controller } from "@hotwired/stimulus";
import { fetchTurboContent } from "../utils";

// Connects to data-controller="bulk-action"
export default class extends Controller {
  static values = {
    scope: String,
  };

  connect() {
    this.selectedIds = [];

    document.addEventListener("bulk-action-modal-opened", (event) => {
      this._modalOpened(event);
    });
  }

  disconnect() {
    document.removeEventListener("bulk-action-modal-opened", this._modalOpened);
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
  }

  toggle(event) {
    const id = event.target.value;

    if (event.target.checked) {
      // Add ID to the array if the checkbox is checked
      this.selectedIds.push(id);
    } else {
      // Remove ID from the array if the checkbox is unchecked
      this.selectedIds = this.selectedIds.filter(
        (selectedId) => selectedId !== id
      );
    }

    if (this.selectedIds.length > 0) {
      this._enableActions();
    } else {
      this._disableActions();
    }

    this._persist();
    // console.log(`${this.scopeValue} select one`, this.selectedIds.length);
  }

  toggleAll(event) {
    if (event.target.checked) {
      this._selectAll();
    } else {
      this._unselectAll();
    }
  }

  _modalOpened(event) {
    if (event.detail.scope !== this.scopeValue) {
      return;
    }

    const modal = this._withModal();

    this._populateCountElements(modal);
    this._populateIds(modal);
    this._addProcessor(modal, event.detail.modalId);
  }

  _populateCountElements(modal) {
    const countElements = modal.querySelectorAll("span.count");
    countElements.forEach((countElement) => {
      countElement.textContent = this.selectedIds.length;
    });
  }

  _addProcessor(modal, processor) {
    const form = modal.querySelector("form");
    const hiddenInput = document.createElement("input");
    hiddenInput.type = "hidden";
    hiddenInput.name = "processor";
    hiddenInput.value = processor;
    form.appendChild(hiddenInput);
  }

  _populateIds(modal) {
    const form = modal.querySelector("form");
    const hiddenInput = document.createElement("input");
    hiddenInput.type = "hidden";
    hiddenInput.name = "ids";
    hiddenInput.value = JSON.stringify(this.selectedIds);
    form.appendChild(hiddenInput);
  }

  _withModal() {
    return document.querySelector(`#modalx_${this.scopeValue}`);
  }

  _selectAll() {
    // find all checkboxes with the name of the actionScope
    const checkboxes = document.querySelectorAll(
      `.bulk-action-checkbox > input[name="${this.scopeValue}"]`
    );

    this.selectedIds = Array.from(checkboxes).map((checkbox) => checkbox.value);

    Array.from(checkboxes).forEach((checkbox) => {
      checkbox.checked = true;
    });

    this._persist();
    this._enableActions();
    // console.log(`${this.scopeValue} select all`, this.selectedIds.length);
  }

  _unselectAll() {
    this.selectedIds = [];
    const checkboxes = document.querySelectorAll(
      `.bulk-action-checkbox > input[name="${this.scopeValue}"]`
    );
    Array.from(checkboxes).forEach((checkbox) => {
      checkbox.checked = false;
    });

    this._persist();
    this._disableActions();
    // console.log(`${this.scopeValue} unselect all`, this.selectedIds.length);
  }

  _persist() {
    this.element.dataset.ids = JSON.stringify(this.selectedIds);
    // console.log("persist", this.element.dataset.ids);
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
}
