import { Controller } from "@hotwired/stimulus";
import { fetchTurboContent } from "../utils";

// Connects to data-controller="pagination"
export default class extends Controller {
  connect() {}

  paginate(event) {
    const path = event.target.dataset.resourcePath;

    fetchTurboContent(event, path);
  }

  changePerPage(event) {
    const newPerPage = event.target.value;
    const pathTemplate = event.target.dataset.perPagePath;
    const path = pathTemplate.replace("__PER_PAGE__", newPerPage);

    fetchTurboContent(event, path);
  }
}
