/**
 * Submit button: lock on submit, spinner while saving, ✓ / ✕ result until the form is touched.
 *
 * Turbo is not loaded here; its lifecycle is simulated with the events it dispatches on the form
 * (turbo:submit-start, turbo:before-fetch-response, turbo:submit-end).
 */

import { Application } from '@hotwired/stimulus';
import SubmitButtonController, { clearHandoff } from '../../../lib/flexi_admin/javascript/controllers/submit_button_controller';

const tick = (ms = 0) => new Promise((resolve) => setTimeout(resolve, ms));

const fetchResponse = ({ status = 200, header = null } = {}) => ({
  succeeded: status >= 200 && status < 300,
  header: (name) => (name === 'X-FlexiAdmin-Submit-Result' ? header : null),
});

const formHTML = (id = 'user_1', buttonAttrs = '') => `
  <form id="${id}">
    <input name="user[full_name]" value="Jan">
    <button type="submit" class="btn btn-primary btn-sm" data-controller="submit-button" ${buttonAttrs}>
      <span class="fa-submit-indicator" data-submit-button-target="indicator"><i class="bi bi-save me-2"></i></span>
      <span class="fa-submit-label">Uložit</span>
    </button>
  </form>`;

describe('SubmitButtonController', () => {
  let application;

  const mount = async (html = formHTML()) => {
    document.body.innerHTML = html;
    application = Application.start();
    application.register('submit-button', SubmitButtonController);
    await tick();
  };

  const button = () => document.querySelector('[data-controller="submit-button"]');
  const form = () => document.querySelector('form');

  // A submit that Turbo takes over: Turbo calls preventDefault on it.
  const submit = (target = form()) => {
    const event = new Event('submit', { bubbles: true, cancelable: true });
    target.addEventListener('submit', (e) => e.preventDefault(), { once: true });
    target.dispatchEvent(event);
    return event;
  };

  const turbo = (name, detail = {}, target = form()) =>
    target.dispatchEvent(new CustomEvent(`turbo:${name}`, { bubbles: true, detail }));

  const respond = (response, { success = response.succeeded, target = form() } = {}) => {
    turbo('before-fetch-response', { fetchResponse: response }, target);
    turbo('submit-end', { success, fetchResponse: response }, target);
  };

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    clearHandoff();
  });

  describe('double-click on save (hriste QA F4: two orders created from one modal)', () => {
    it('swallows the second submit before it reaches Turbo, so the request goes out once', async () => {
      await mount();
      const reachedDocument = jest.fn();
      document.addEventListener('submit', reachedDocument);

      submit();
      turbo('submit-start');
      submit();

      expect(reachedDocument).toHaveBeenCalledTimes(1);
      document.removeEventListener('submit', reachedDocument);
    });

    it('disables the button and marks it busy so the user sees it is already working', async () => {
      await mount();

      submit();

      expect(button().disabled).toBe(true);
      expect(button().getAttribute('aria-busy')).toBe('true');
      expect(button().dataset.submitState).toBe('pending');
      expect(button().querySelector('.spinner-border')).not.toBeNull();
    });
  });

  describe('bulk-action modal: "Spustit" sits outside the <form> and calls requestSubmit()', () => {
    const modalHTML = `
      <div class="modal"><div class="modal-content">
        <div class="modal-body"><form id="form"><select name="format"><option>csv</option></select></form></div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-primary" data-controller="submit-button">
            <span data-submit-button-target="indicator"></span><span>Spustit</span>
          </button>
        </div>
      </div></div>`;

    it('finds the modal form and locks on its submit, which Turbo would not do (no submitter)', async () => {
      await mount(modalHTML);

      submit();

      expect(button().disabled).toBe(true);
    });

    it('still blocks a second requestSubmit() from a fast double-click', async () => {
      await mount(modalHTML);
      const reachedDocument = jest.fn();
      document.addEventListener('submit', reachedDocument);

      submit();
      submit();

      expect(reachedDocument).toHaveBeenCalledTimes(1);
      document.removeEventListener('submit', reachedDocument);
    });
  });

  describe('what counts as an issue', () => {
    it('trusts the server header: gem validation failures come back 200 with the form re-rendered', async () => {
      await mount();
      submit();
      turbo('submit-start');

      respond(fetchResponse({ status: 200, header: 'error' }));

      expect(button().dataset.submitState).toBe('error');
      expect(button().querySelector('.bi-x-lg')).not.toBeNull();
      expect(button().classList.contains('btn-danger')).toBe(true);
      expect(button().classList.contains('btn-primary')).toBe(false);
    });

    it('shows ✓ for a plain 2xx when the host action sets no header', async () => {
      await mount();
      submit();
      turbo('submit-start');

      respond(fetchResponse({ status: 200 }));

      expect(button().dataset.submitState).toBe('success');
      expect(button().querySelector('.bi-check-lg')).not.toBeNull();
      expect(button().classList.contains('btn-success')).toBe(true);
    });

    it('shows ✕ for a 422 / 5xx, the Rails convention for "not saved"', async () => {
      await mount();
      submit();
      turbo('submit-start');

      respond(fetchResponse({ status: 422 }));

      expect(button().dataset.submitState).toBe('error');
    });

    it('shows ✕ on a network failure, where Turbo has no response at all', async () => {
      await mount();
      submit();
      turbo('submit-start');

      turbo('submit-end', { success: false, error: new TypeError('Failed to fetch') });

      expect(button().dataset.submitState).toBe('error');
    });

    it('unlocks with the result so the user can fix the form and try again', async () => {
      await mount();
      submit();
      turbo('submit-start');

      respond(fetchResponse({ status: 422 }));

      expect(button().disabled).toBe(false);
      expect(button().hasAttribute('aria-busy')).toBe(false);
    });
  });

  describe('the result is stale once the user edits the form again', () => {
    it.each(['input', 'change'])('clears on %s and restores the original icon and colour', async (type) => {
      await mount();
      submit();
      turbo('submit-start');
      respond(fetchResponse({ status: 200, header: 'error' }));

      form().querySelector('input').dispatchEvent(new Event(type, { bubbles: true }));

      expect(button().dataset.submitState).toBe('idle');
      expect(button().querySelector('.bi-save')).not.toBeNull();
      expect(button().className).toBe('btn btn-primary btn-sm');
    });
  });

  describe('the response replaces the whole form (turbo_stream.replace on update/create)', () => {
    it('hands the result to the re-rendered button, since the clicked one is gone', async () => {
      await mount();
      submit();
      turbo('submit-start');
      turbo('before-fetch-response', { fetchResponse: fetchResponse({ header: 'error' }) });

      form().outerHTML = formHTML('user_1');
      await tick();

      expect(button().dataset.submitState).toBe('error');
    });

    it('does not paint the result onto a different form rendered by the same response', async () => {
      await mount();
      submit();
      turbo('submit-start');
      turbo('before-fetch-response', { fetchResponse: fetchResponse({ header: 'success' }) });

      form().outerHTML = formHTML('user_2');
      await tick();

      expect(button().dataset.submitState).toBe('idle');
    });

    it('ignores a hand-off older than handoffMs (e.g. Cancel re-renders the form later)', async () => {
      await mount(formHTML('user_1', 'data-submit-button-handoff-ms-value="10"'));
      submit();
      turbo('submit-start');
      turbo('before-fetch-response', { fetchResponse: fetchResponse({ header: 'success' }) });

      await tick(30);
      form().outerHTML = formHTML('user_1', 'data-submit-button-handoff-ms-value="10"');
      await tick();

      expect(button().dataset.submitState).toBe('idle');
    });

    it('keeps a button rendered disabled (read-only form after save) disabled while showing ✓', async () => {
      await mount();
      submit();
      turbo('submit-start');
      turbo('before-fetch-response', { fetchResponse: fetchResponse({ header: 'success' }) });

      form().outerHTML = formHTML('user_1', 'disabled');
      await tick();

      expect(button().dataset.submitState).toBe('success');
      expect(button().disabled).toBe(true);
    });
  });

  describe('a submit that never actually goes out', () => {
    it('unlocks when another listener cancels it and Turbo never starts', async () => {
      await mount();

      submit();
      await tick(80);

      expect(button().dataset.submitState).toBe('idle');
      expect(button().disabled).toBe(false);
    });

    it('does not lock for target="_blank" forms, whose page stays here', async () => {
      await mount(formHTML().replace('<form id="user_1">', '<form id="user_1" target="_blank">'));

      submit();

      expect(button().dataset.submitState).toBe('idle');
    });
  });
});
