import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="submit-button" (on the submit <button> itself).
//
// idle -> pending (locked, spinner) -> success (✓) | error (✕) -> idle once any field of the form is touched.
//
// Which form: the button's own form (button.form, incl. a form="id" attribute), else the
// data-submit-button-form-value CSS selector, else the first <form> in the enclosing .modal
// (the bulk-action modal puts "Spustit" outside its form and calls form.requestSubmit()).
//
// What counts as an issue: the X-FlexiAdmin-Submit-Result response header when present
// (ResourcesController sets it, because a validation failure comes back as 200 + re-rendered form);
// otherwise any non-2xx status, a network failure, or a Turbo error.
//
// The response often replaces the whole form (turbo_stream.replace), so the button that was clicked is
// gone before it could show the result. The result is therefore parked per form id for handoffMs and
// picked up by the re-rendered button when it connects.
//
// Recipes:
//   any button:            <button type="submit" data-controller="submit-button">…</button>
//   button outside a form: add data-submit-button-form-value="#my-form"
//   custom server action:  call fa_submit_result(:error) in the controller (or answer with 422)
//   opt out:               FlexiAdmin::Config.configure { |c| c.submit_button_states = false },
//                          submit('Uložit', submit_state: false), modal(context, submit_state: false)
//   tune:                  data-submit-button-handoff-ms-value (default 2000),
//                          data-submit-button-native-unlock-ms-value (default 10000),
//                          data-submit-button-{success,error}-class="…" (default btn-success / btn-danger)

export const RESULT_HEADER = "X-FlexiAdmin-Submit-Result";

const ICONS = {
  pending: '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>',
  success: '<i class="bi bi-check-lg me-2" aria-hidden="true"></i>',
  error: '<i class="bi bi-x-lg me-2" aria-hidden="true"></i>',
};
const DEFAULT_CLASSES = { success: "btn-success", error: "btn-danger" };
// Bootstrap colour variants to drop while a result colour is shown (size classes like btn-sm stay).
const VARIANT_CLASS = /^btn-(outline-)?(primary|secondary|success|danger|warning|info|light|dark|link)$/;

// formId -> { result, at }
const handoff = new Map();

export function resultFromResponse(fetchResponse) {
  const header = fetchResponse?.header?.(RESULT_HEADER);
  if (header === "success" || header === "error") return header;
  return fetchResponse?.succeeded ? "success" : "error";
}

export function clearHandoff() {
  handoff.clear();
}

export default class extends Controller {
  static targets = ["indicator"];
  static classes = ["success", "error"];
  static values = {
    form: String,
    handoffMs: { type: Number, default: 2000 },
    nativeUnlockMs: { type: Number, default: 10000 },
  };

  connect() {
    this.state = "idle";
    this.element.dataset.submitState = "idle";
    this.originalIndicator = this.hasIndicatorTarget ? this.indicatorTarget.innerHTML : null;
    this.originalClassName = this.element.className;
    // A button rendered disabled (read-only form) stays disabled whatever state it shows.
    this.renderedDisabled = this.element.disabled;
    this.form = this._resolveForm();
    if (!this.form) return;

    this._listen(true);
    this._pickUpHandoff();
  }

  disconnect() {
    if (this.form) this._listen(false);
    clearTimeout(this.nativeUnlockTimer);
    clearTimeout(this.cancelCheck);
  }

  // --- events -------------------------------------------------------------------------------

  // Runs at the form, i.e. before Turbo's document-level listener, so a second submit
  // (Enter in a field, requestSubmit() from the modal button) never reaches Turbo.
  onSubmit = (event) => {
    if (this.state === "pending") {
      event.preventDefault();
      event.stopImmediatePropagation();
      return;
    }
    if (this._targetsOtherWindow(event)) return;

    this.turboStarted = false;
    this.receivedResult = null;
    this._render("pending");

    // Turbo (or a validation listener) may take the event over; that only shows after dispatch.
    setTimeout(() => {
      if (this.state !== "pending" || this.turboStarted) return;
      if (event.defaultPrevented) {
        // Turbo starts asynchronously; if it never does, someone cancelled the submit.
        this.cancelCheck = setTimeout(() => {
          if (this.state === "pending" && !this.turboStarted) this._render("idle");
        }, 50);
      } else {
        // Native (non-Turbo) submit: the page is about to unload. If it does not (download,
        // target=_blank), give the button back eventually.
        this.nativeUnlockTimer = setTimeout(() => this._render("idle"), this.nativeUnlockMsValue);
      }
    }, 0);
  };

  onSubmitStart = () => {
    this.turboStarted = true;
    clearTimeout(this.cancelCheck);
    if (this.state !== "pending") this._render("pending");
  };

  onBeforeFetchResponse = (event) => {
    const result = resultFromResponse(event.detail?.fetchResponse);
    this.receivedResult = result;
    const id = this._formId();
    if (id) handoff.set(id, { result, at: Date.now() });
  };

  onSubmitEnd = (event) => {
    const result = this.receivedResult || (event.detail?.success ? "success" : "error");
    this._render(result);
  };

  onTouched = () => {
    if (this.state === "success" || this.state === "error") this._render("idle");
  };

  // bfcache restore after a native submit + Back: the page comes back frozen mid-"pending".
  onPageShow = (event) => {
    if (event.persisted && this.state === "pending") this._render("idle");
  };

  // --- internals ----------------------------------------------------------------------------

  _listen(on) {
    const method = on ? "addEventListener" : "removeEventListener";
    this.form[method]("submit", this.onSubmit, true);
    this.form[method]("turbo:submit-start", this.onSubmitStart);
    this.form[method]("turbo:before-fetch-response", this.onBeforeFetchResponse);
    this.form[method]("turbo:submit-end", this.onSubmitEnd);
    this.form[method]("input", this.onTouched);
    this.form[method]("change", this.onTouched);
    window[method]("pageshow", this.onPageShow);
  }

  _pickUpHandoff() {
    const id = this._formId();
    const entry = id && handoff.get(id);
    if (!entry) return;
    handoff.delete(id);
    if (Date.now() - entry.at <= this.handoffMsValue) this._render(entry.result);
  }

  // getAttribute, not form.id: an <input name="id"> inside the form shadows the property.
  _formId() {
    return this.form.getAttribute("id");
  }

  _resolveForm() {
    if (this.element.form) return this.element.form;
    if (this.hasFormValue && this.formValue) return document.querySelector(this.formValue);
    return this.element.closest(".modal")?.querySelector("form") || null;
  }

  _targetsOtherWindow(event) {
    const target = event.submitter?.getAttribute("formtarget") || this.form.getAttribute("target");
    return !!target && target !== "_self";
  }

  _render(state) {
    this.state = state;
    clearTimeout(this.nativeUnlockTimer);
    const el = this.element;

    el.className = this.originalClassName;
    if (state === "success" || state === "error") {
      el.classList.forEach((c) => VARIANT_CLASS.test(c) && el.classList.remove(c));
      el.classList.add(...this._resultClass(state).split(/\s+/).filter(Boolean));
    }

    el.dataset.submitState = state;
    el.disabled = state === "pending" || this.renderedDisabled;
    if (state === "pending") el.setAttribute("aria-busy", "true");
    else el.removeAttribute("aria-busy");

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.innerHTML = state === "idle" ? this.originalIndicator : ICONS[state];
    }
  }

  _resultClass(state) {
    if (state === "success" && this.hasSuccessClass) return this.successClass;
    if (state === "error" && this.hasErrorClass) return this.errorClass;
    return DEFAULT_CLASSES[state];
  }
}
