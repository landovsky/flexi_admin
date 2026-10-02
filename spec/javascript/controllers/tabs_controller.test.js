/**
 * Tabs controller: keeps a TabsComponent's open tab in the URL hash so a reload or a
 * shared link reopens it.
 */

import { Application } from '@hotwired/stimulus';
import TabsController from '../../../lib/flexi_admin/javascript/controllers/tabs_controller';

describe('TabsController', () => {
  let application;

  const mount = async () => {
    document.body.innerHTML = `
      <div data-controller="tabs">
        <button class="active" data-tabs-key-param="prehled" data-action="click->tabs#remember">Přehled</button>
        <button data-tabs-key-param="kalkulace" data-action="click->tabs#remember">Kalkulace</button>
      </div>`;
    application = Application.start();
    application.register('tabs', TabsController);
    await Promise.resolve();
  };

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    history.replaceState(null, '', '/');
  });

  describe('a link shared with a #kalkulace hash', () => {
    it('opens that tab on connect instead of the first one', async () => {
      history.replaceState(null, '', '/#kalkulace');
      const clicked = jest.fn();
      document.addEventListener('click', (e) => clicked(e.target.dataset.tabsKeyParam), { once: true });

      await mount();

      expect(clicked).toHaveBeenCalledWith('kalkulace');
    });
  });

  describe('a hash naming no tab of this set (e.g. an in-page anchor)', () => {
    it('leaves the default tab open', async () => {
      history.replaceState(null, '', '/#somewhere-else');
      const clicked = jest.fn();
      document.addEventListener('click', clicked, { once: true });

      await mount();

      expect(clicked).not.toHaveBeenCalled();
    });
  });

  describe('the user switches tabs', () => {
    it('writes the tab key into the URL hash without adding a history entry', async () => {
      await mount();
      const before = history.length;

      document.querySelector('[data-tabs-key-param="kalkulace"]').click();

      expect(window.location.hash).toBe('#kalkulace');
      expect(history.length).toBe(before);
    });
  });
});
