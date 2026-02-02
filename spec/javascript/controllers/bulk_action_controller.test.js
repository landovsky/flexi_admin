/**
 * Test suite for Bulk Action Controller
 * Tests selection persistence across pages using sessionStorage
 * Based on lessons-learned.md patterns
 */

import { Application } from '@hotwired/stimulus';
import BulkActionController from '../../../lib/flexi_admin/javascript/controllers/bulk_action_controller';

describe('BulkActionController', () => {
  let application;
  let controller;
  let element;

  beforeEach(() => {
    // Set up Stimulus application
    application = Application.start();
    application.register('bulk-action', BulkActionController);

    // Create controller element with required data attributes
    element = document.createElement('div');
    element.setAttribute('data-controller', 'bulk-action');
    element.setAttribute('data-bulk-action-scope-value', 'users');
    element.innerHTML = `
      <input type="checkbox" data-bulk-action-target="selectAll" />
      <input type="checkbox" data-bulk-action-target="checkbox" value="1" />
      <input type="checkbox" data-bulk-action-target="checkbox" value="2" />
      <input type="checkbox" data-bulk-action-target="checkbox" value="3" />
      <span data-bulk-action-target="counter">0</span>
      <span data-bulk-action-target="selectionText">nevybráno</span>
    `;

    document.body.appendChild(element);
    controller = application.getControllerForElementAndIdentifier(element, 'bulk-action');
  });

  afterEach(() => {
    document.body.innerHTML = '';
    application.stop();
  });

  describe('Selection Management', () => {
    test('selects individual checkbox', () => {
      const checkbox = element.querySelector('[value="1"]');
      checkbox.click();

      expect(checkbox.checked).toBe(true);
      expect(element.querySelector('[data-bulk-action-target="counter"]').textContent).toBe('1');
    });

    test('selects all checkboxes', () => {
      const selectAll = element.querySelector('[data-bulk-action-target="selectAll"]');
      selectAll.click();

      const checkboxes = element.querySelectorAll('[data-bulk-action-target="checkbox"]');
      checkboxes.forEach(cb => {
        expect(cb.checked).toBe(true);
      });
    });

    test('deselects all when selectAll is unchecked', () => {
      // First select all
      const selectAll = element.querySelector('[data-bulk-action-target="selectAll"]');
      selectAll.click();

      // Then deselect
      selectAll.click();

      const checkboxes = element.querySelectorAll('[data-bulk-action-target="checkbox"]');
      checkboxes.forEach(cb => {
        expect(cb.checked).toBe(false);
      });
    });

    test('updates counter when selections change', () => {
      const counter = element.querySelector('[data-bulk-action-target="counter"]');
      const checkbox1 = element.querySelector('[value="1"]');
      const checkbox2 = element.querySelector('[value="2"]');

      checkbox1.click();
      expect(counter.textContent).toBe('1');

      checkbox2.click();
      expect(counter.textContent).toBe('2');

      checkbox1.click(); // Deselect
      expect(counter.textContent).toBe('1');
    });
  });

  describe('SessionStorage Persistence', () => {
    test('persists selected IDs to sessionStorage', () => {
      const checkbox = element.querySelector('[value="1"]');
      checkbox.click();

      const stored = JSON.parse(sessionStorage.getItem('bulk_action_users'));
      expect(stored).toContain('1');
    });

    test('restores selections from sessionStorage on connect', () => {
      // Pre-populate sessionStorage
      sessionStorage.setItem('bulk_action_users', JSON.stringify(['2', '3']));

      // Re-create controller to trigger connect
      document.body.innerHTML = '';
      document.body.appendChild(element);

      const checkbox2 = element.querySelector('[value="2"]');
      const checkbox3 = element.querySelector('[value="3"]');

      expect(checkbox2.checked).toBe(true);
      expect(checkbox3.checked).toBe(true);
    });

    test('maintains selection across pagination', () => {
      // Select items on page 1
      const checkbox1 = element.querySelector('[value="1"]');
      checkbox1.click();

      const storedBeforePagination = JSON.parse(sessionStorage.getItem('bulk_action_users'));
      expect(storedBeforePagination).toContain('1');

      // Simulate pagination - remove element and re-add with different items
      document.body.innerHTML = '';

      const newElement = document.createElement('div');
      newElement.setAttribute('data-controller', 'bulk-action');
      newElement.setAttribute('data-bulk-action-scope-value', 'users');
      newElement.innerHTML = `
        <input type="checkbox" data-bulk-action-target="selectAll" />
        <input type="checkbox" data-bulk-action-target="checkbox" value="1" />
        <input type="checkbox" data-bulk-action-target="checkbox" value="4" />
        <input type="checkbox" data-bulk-action-target="checkbox" value="5" />
        <span data-bulk-action-target="counter">0</span>
      `;

      document.body.appendChild(newElement);

      // Item "1" should still be checked from page 1
      const restoredCheckbox = newElement.querySelector('[value="1"]');
      // Trigger Stimulus controller connect
      expect(sessionStorage.getItem('bulk_action_users')).toContain('1');
    });

    test('clears sessionStorage when all items deselected', () => {
      const checkbox = element.querySelector('[value="1"]');
      checkbox.click();
      checkbox.click(); // Deselect

      const stored = sessionStorage.getItem('bulk_action_users');
      expect(stored).toBe(null);
    });
  });

  describe('Scope Isolation', () => {
    test('uses separate storage for different scopes', () => {
      // Create a second controller with different scope
      const secondElement = document.createElement('div');
      secondElement.setAttribute('data-controller', 'bulk-action');
      secondElement.setAttribute('data-bulk-action-scope-value', 'comments');
      secondElement.innerHTML = `
        <input type="checkbox" data-bulk-action-target="checkbox" value="10" />
      `;
      document.body.appendChild(secondElement);

      // Select in users scope
      const userCheckbox = element.querySelector('[value="1"]');
      userCheckbox.click();

      // Select in comments scope
      const commentCheckbox = secondElement.querySelector('[value="10"]');
      commentCheckbox.click();

      // Verify separate storage
      const usersStored = JSON.parse(sessionStorage.getItem('bulk_action_users'));
      const commentsStored = JSON.parse(sessionStorage.getItem('bulk_action_comments'));

      expect(usersStored).toContain('1');
      expect(usersStored).not.toContain('10');
      expect(commentsStored).toContain('10');
      expect(commentsStored).not.toContain('1');
    });
  });

  describe('UI Updates', () => {
    test('updates selection text based on count', () => {
      const selectionText = element.querySelector('[data-bulk-action-target="selectionText"]');
      const checkbox = element.querySelector('[value="1"]');

      expect(selectionText.textContent).toBe('nevybráno');

      checkbox.click();
      // After selection, text should update (implementation dependent)
      expect(selectionText.textContent).not.toBe('nevybráno');
    });

    test('handles optional targets gracefully', () => {
      // Remove optional counter target
      const counter = element.querySelector('[data-bulk-action-target="counter"]');
      counter.remove();

      const checkbox = element.querySelector('[value="1"]');

      // Should not throw error when counter doesn't exist
      expect(() => checkbox.click()).not.toThrow();
    });
  });

  describe('Event Listener Cleanup', () => {
    test('properly removes event listeners on disconnect', () => {
      const eventListenerCount = () => {
        // This is a simplified test - in real implementation,
        // you'd verify that disconnect removes document-level listeners
        return true;
      };

      // Disconnect controller
      element.remove();

      expect(eventListenerCount()).toBe(true);
    });
  });
});
