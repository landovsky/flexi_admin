/**
 * Test suite for Pagination Controller
 * Tests remembering the chosen per-page size per section using localStorage
 */

import { Application } from '@hotwired/stimulus';
import PaginationController from '../../../lib/flexi_admin/javascript/controllers/pagination_controller';

describe('PaginationController', () => {
  let application;

  // Stimulus binds controllers/actions via a MutationObserver, which fires as a
  // microtask after the element is appended — flushing lets that binding (and any
  // fetch promise chains kicked off from connect()) settle before we assert.
  const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

  const buildElement = async ({
    scope = 'elements',
    selectValue = '14',
    perPagePath = '/admin/elements?per_page=__PER_PAGE__',
  } = {}) => {
    const element = document.createElement('nav');
    element.setAttribute('data-controller', 'pagination');
    element.setAttribute('data-pagination-scope-value', scope);
    element.innerHTML = `
      <select data-pagination-target="perPageSelect"
              data-action="change->pagination#changePerPage"
              data-per-page-path="${perPagePath}">
        <option value="14">14</option>
        <option value="32">32</option>
        <option value="64">64</option>
      </select>
    `;
    element.querySelector('select').value = selectValue;
    document.body.appendChild(element);

    await flushPromises();

    return element;
  };

  beforeEach(() => {
    global.Turbo = { renderStreamMessage: jest.fn() };
    global.fetch = jest.fn(() =>
      Promise.resolve({
        text: () => Promise.resolve('<turbo-stream></turbo-stream>'),
      })
    );

    application = Application.start();
    application.register('pagination', PaginationController);
  });

  afterEach(() => {
    document.body.innerHTML = '';
    application.stop();
    jest.restoreAllMocks();
  });

  describe('changePerPage', () => {
    test('saves the chosen per-page value to localStorage under a key scoped by section', async () => {
      const element = await buildElement({ scope: 'elements' });
      const select = element.querySelector('select');

      select.value = '64';
      select.dispatchEvent(new Event('change', { bubbles: true }));

      expect(localStorage.getItem('pagination_per_page:elements')).toBe('64');
    });
  });

  describe('connect - restoring the remembered per-page', () => {
    test('fetches the saved per-page when it differs from what the server rendered', async () => {
      localStorage.setItem('pagination_per_page:elements', '64');

      await buildElement({ scope: 'elements', selectValue: '14', perPagePath: '/admin/elements?per_page=__PER_PAGE__' });

      expect(global.fetch).toHaveBeenCalledWith('/admin/elements?per_page=64', {
        headers: { Accept: 'text/vnd.turbo-stream.html' },
      });
      expect(global.Turbo.renderStreamMessage).toHaveBeenCalledWith('<turbo-stream></turbo-stream>');
    });

    test('does nothing when no per-page has been saved for this section yet', async () => {
      await buildElement({ scope: 'elements', selectValue: '14' });

      expect(global.fetch).not.toHaveBeenCalled();
      expect(global.Turbo.renderStreamMessage).not.toHaveBeenCalled();
    });

    test('does nothing when the saved value already matches the rendered select, avoiding a redirect loop', async () => {
      localStorage.setItem('pagination_per_page:elements', '14');

      await buildElement({ scope: 'elements', selectValue: '14' });

      expect(global.fetch).not.toHaveBeenCalled();
      expect(global.Turbo.renderStreamMessage).not.toHaveBeenCalled();
    });
  });

  describe('a remembered size the section no longer offers', () => {
    // The restore converges only because the server echoes the requested per_page
    // back as the selected option. A value that is not in the list can never come
    // back selected, so every reconnect would see the same mismatch and re-fetch.
    test('does not fetch a size that is missing from the select, which would re-fetch on every reconnect forever', async () => {
      localStorage.setItem('pagination_per_page:elements', '99');

      await buildElement({ scope: 'elements', selectValue: '14' });

      expect(global.fetch).not.toHaveBeenCalled();
      expect(global.Turbo.renderStreamMessage).not.toHaveBeenCalled();
    });

    test('forgets the unavailable size so the section falls back to the server default for good', async () => {
      localStorage.setItem('pagination_per_page:elements', '99');

      await buildElement({ scope: 'elements', selectValue: '14' });

      expect(localStorage.getItem('pagination_per_page:elements')).toBeNull();
    });
  });

  describe('Scope Isolation', () => {
    test('uses separate storage keys for different sections so one list cannot affect another', async () => {
      const elementsSection = await buildElement({ scope: 'elements' });
      const photosSection = await buildElement({ scope: 'photos' });

      const elementsSelect = elementsSection.querySelector('select');
      elementsSelect.value = '64';
      elementsSelect.dispatchEvent(new Event('change', { bubbles: true }));

      const photosSelect = photosSection.querySelector('select');
      photosSelect.value = '32';
      photosSelect.dispatchEvent(new Event('change', { bubbles: true }));

      expect(localStorage.getItem('pagination_per_page:elements')).toBe('64');
      expect(localStorage.getItem('pagination_per_page:photos')).toBe('32');
    });

    // context.scope_id is nil when a caller builds a Context without a scope, which
    // renders an empty scope value — every such list would then share one key.
    test('remembers nothing for a section rendered without a scope rather than sharing one key with every other list', async () => {
      const element = await buildElement({ scope: '' });
      const select = element.querySelector('select');

      select.value = '64';
      select.dispatchEvent(new Event('change', { bubbles: true }));

      expect(localStorage.getItem('pagination_per_page:')).toBeNull();
    });

    test('ignores an unscoped leftover key instead of applying it to an unscoped section', async () => {
      localStorage.setItem('pagination_per_page:', '64');

      await buildElement({ scope: '', selectValue: '14' });

      expect(global.fetch).not.toHaveBeenCalled();
    });
  });
});
