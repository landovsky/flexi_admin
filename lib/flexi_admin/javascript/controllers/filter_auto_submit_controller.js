import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="filter-auto-submit"
export default class extends Controller {
  initialize() {
    this.initialValues = new Map();
    this.storageKey = 'filterAutoSubmit_openDropdowns';
  }

  connect() {
    this.getInputFields().forEach((field) => {
      this.initialValues.set(field, field.value);
    });

    this.reopenDropdowns();
  }

  reopenDropdowns() {
    const openDropdownIds = this.getOpenDropdownIds();
    if (openDropdownIds.length > 0) {
      setTimeout(() => {
        openDropdownIds.forEach((dropdownId) => {
          const button = this.element.querySelector(`#${dropdownId}`);
          if (button) {
            const dropdown = new bootstrap.Dropdown(button);
            dropdown.show();
          }
        });
        sessionStorage.removeItem(this.storageKey);
      }, 100);
    }
  }

  getOpenDropdownIds() {
    try {
      const stored = sessionStorage.getItem(this.storageKey);
      return stored ? JSON.parse(stored) : [];
    } catch (e) {
      return [];
    }
  }

  storeOpenDropdownIds(ids) {
    try {
      sessionStorage.setItem(this.storageKey, JSON.stringify(ids));
    } catch (e) {
    }
  }

  handleDropdownChange(event) {
    event.stopPropagation();

    const openDropdownIds = [];
    this.element.querySelectorAll('.dropdown-menu.show').forEach((menu) => {
      const button = menu.previousElementSibling;
      if (button && button.id) {
        openDropdownIds.push(button.id);
      }
    });

    this.storeOpenDropdownIds(openDropdownIds);

    this.element.requestSubmit();
  }

  submitOnBlur(event) {
    let field = null;

    if (event.target.matches('input, textarea')) {
      field = event.target;
    } else {
      field = event.target.querySelector('input, textarea');
    }

    if (!field) return;

    if (this.initialValues.get(field) !== field.value) {
      this.element.requestSubmit();
    }
  }

  getInputFields() {
    return Array.from(
      this.element.querySelectorAll('input[type="text"], input[type="search"], textarea')
    );
  }
}
