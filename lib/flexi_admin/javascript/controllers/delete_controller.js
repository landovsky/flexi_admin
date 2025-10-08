import { Controller } from "@hotwired/stimulus";
import { CSRFToken } from "../utils";

// Connects to data-controller="delete"
export default class extends Controller {
  static values = {
    resourcePath: String,
    confirmMessage: String,
    disabled: Boolean,
  };

  delete(event) {
    event.preventDefault();

    if (this.disabledValue) {
      return;
    }

    const confirmMessage = this.confirmMessageValue || "Are you sure you want to delete this item?";

    if (!confirm(confirmMessage)) {
      return;
    }

    fetch(this.resourcePathValue, {
      method: "DELETE",
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": CSRFToken(),
      },
    })
      .then((response) => response.text())
      .then((html) => {
        Turbo.renderStreamMessage(html);
      })
      .catch((error) => {
        console.error("Error deleting resource:", error);
      });
  }
}
