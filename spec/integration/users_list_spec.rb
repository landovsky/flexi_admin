# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users List Page', type: :feature, js: true do
  before do
    # Create test data matching ui-test-cases.md scenarios
    create(:user, :balicka)
    create(:user, :effenberger)
    create_list(:user, 20)  # Create enough users for pagination
  end

  describe 'Search & Filter' do
    # UL-001: Search by Full Name
    it 'searches users by full name' do
      visit '/admin/users?q=Balicka'

      expect(page).to have_content('Balická')
      expect(page).not_to have_content('Effenberger')
    end

    # UL-002: Search by Email
    it 'searches users by email' do
      visit '/admin/users?q=balicka@hristehrou.cz'

      expect(page).to have_content('balicka@hristehrou.cz')
    end

    # UL-003: Search by Partial Text
    it 'searches with partial text match' do
      visit '/admin/users?q=effen'

      expect(page).to have_content('Effenberger')
    end

    # UL-004: Filter by Role
    it 'filters users by role' do
      visit '/admin/users'

      within('.filter-bar') do
        select 'Admin', from: 'role'
      end

      expect(page).to have_content('Balická')  # Admin user
    end

    # UL-005: Clear Filters
    it 'clears all filters when clicking Zrušit' do
      visit '/admin/users?q=test&role=admin'

      within('.filter-bar') do
        click_button 'Zrušit'
      end

      # Should show all users again
      expect(page).to have_content('Balická')
      expect(page).to have_content('Effenberger')
    end
  end

  describe 'Sorting' do
    # UL-006: Sort by Full Name
    it 'sorts users by full name' do
      visit '/admin/users'

      # Click the sortable column header (Turbo Stream replaces frame, URL doesn't change)
      within('flexi-table') do
        find('[data-controller="sorting"]', text: 'Jméno').find('a').click
      end

      # After sorting, the sort path should toggle to desc
      within('flexi-table') do
        sort_link = find('[data-controller="sorting"]', text: 'Jméno')
        expect(sort_link['data-sorting-sort-path-value']).to match(/fa_order=desc/)
      end
    end

    # UL-007: Sort by Email
    it 'sorts users by email' do
      visit '/admin/users'

      within('flexi-table') do
        find('[data-controller="sorting"]', text: 'Email').find('a').click
      end

      within('flexi-table') do
        sort_link = find('[data-controller="sorting"]', text: 'Email')
        expect(sort_link['data-sorting-sort-path-value']).to match(/fa_order=desc/)
      end
    end
  end

  describe 'Selection & Bulk Actions' do
    # UL-010: Select All Records
    it 'selects all visible users when clicking header checkbox' do
      visit '/admin/users'

      # Click the "select all" checkbox
      find('#checkbox-all').click

      # All individual checkboxes should be checked
      checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
      expect(checkboxes).to all(be_checked)
    end

    # UL-011: Select Individual Record
    it 'selects individual user row' do
      visit '/admin/users'

      checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
      checkboxes.first.click

      expect(checkboxes.first).to be_checked
    end

    # UL-012: Multi-selection
    it 'maintains selection of multiple users' do
      visit '/admin/users'

      checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
      checkboxes[0].click
      checkboxes[2].click
      checkboxes[4].click

      expect(checkboxes[0]).to be_checked
      expect(checkboxes[2]).to be_checked
      expect(checkboxes[4]).to be_checked
      expect(checkboxes[1]).not_to be_checked
    end

    # UL-013: Selection counter updates
    it 'updates selection counter when users are selected' do
      visit '/admin/users'

      checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
      checkboxes.first.click

      # Selection text should become visible
      expect(find('[data-bulk-action-target="selectionText"]')).to be_visible
      expect(find('[data-bulk-action-target="counter"]').text).to eq('1')
    end

    # UL-014: Selection counter clears
    it 'clears selection when clicking zrušit výběr' do
      visit '/admin/users'

      checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
      checkboxes.first.click

      # Wait for selection text to appear, then clear
      expect(page).to have_css('[data-bulk-action-target="selectionText"]', visible: true)
      click_link 'zrušit výběr'

      # Selection text should be hidden again
      expect(page).to have_css('[data-bulk-action-target="selectionText"]', visible: :hidden)
    end

    # UL-021: Bulk Action - Selected IDs to Controller
    it 'sends selected IDs to controller when submitting bulk action' do
      initial_count = User.count
      visit '/admin/users'

      # Select 2 users (Balická and Effenberger)
      checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
      checkboxes[0].click
      checkboxes[1].click

      # Open actions dropdown and click Delete
      within('.dropdown') do
        click_button 'Akce'
        click_button 'Smazat'
      end

      # Modal should appear with count
      expect(page).to have_css('.modal.show')
      expect(page).to have_content('Opravdu chcete smazat')
      within('.modal') do
        # Count in message body
        expect(all('span.count').first.text).to eq('2')
        # Count in footer "vybraných položek: X"
        expect(page).to have_content('vybraných položek: 2')
      end

      # Submit the form by triggering form submission
      page.execute_script("document.querySelector('#modalx_users form').submit()")

      # Wait for modal to close and page to redirect
      expect(page).to have_no_css('.modal.show', wait: 5)

      # Verify users were actually deleted
      expect(User.count).to eq(initial_count - 2)

      # The page should refresh showing updated count
      expect(page).to have_content("#{initial_count - 2} záznamů")
    end

    # UL-022: Selection-Dependent Action Disabled
    it 'disables selection-dependent actions when nothing is selected' do
      visit '/admin/users'

      # Open actions dropdown
      within('.dropdown') do
        click_button 'Akce'
      end

      # Delete button should be disabled (has .disabled class)
      delete_button = find('.dropdown-item.bulk-action', text: 'Smazat')
      expect(delete_button[:class]).to include('disabled')
    end

    # UL-023: Selection-Independent Action Always Available
    it 'enables selection-independent actions regardless of selection' do
      visit '/admin/users'

      # Open actions dropdown without selecting anything
      within('.dropdown') do
        click_button 'Akce'
      end

      # Export button should NOT be disabled
      export_button = find('.dropdown-item.bulk-action', text: 'Exportovat')
      expect(export_button[:class]).not_to include('disabled')
    end

    # UL-024: Selection-Dependent Action Enabled After Selection
    it 'enables selection-dependent actions after selecting users' do
      visit '/admin/users'

      # Initially disabled
      within('.dropdown') do
        click_button 'Akce'
      end
      delete_button = find('.dropdown-item.bulk-action', text: 'Smazat')
      expect(delete_button[:class]).to include('disabled')

      # Close dropdown and select a user
      find('body').click
      checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
      checkboxes.first.click

      # Re-open dropdown - Delete should now be enabled
      within('.dropdown') do
        click_button 'Akce'
      end
      delete_button = find('.dropdown-item.bulk-action', text: 'Smazat')
      expect(delete_button[:class]).not_to include('disabled')
    end

    # UL-025: Selection Persistence Across Pages and Reload
    it 'persists selection across pages and page reload' do
      visit '/admin/users'

      # Select 2 users
      checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
      checkboxes[0].click
      checkboxes[1].click

      # Verify selection counter shows 2
      expect(find('[data-bulk-action-target="counter"]').text).to eq('2')

      # Navigate to page 2
      within('.pagination') do
        click_link '2'
      end

      # Wait for page to load
      expect(page).to have_css('.page-item.active', text: '2')

      # Selection should persist - counter still shows 2
      expect(find('[data-bulk-action-target="counter"]').text).to eq('2')

      # Go back to page 1
      within('.pagination') do
        click_link '1'
      end

      # Wait for page to load
      expect(page).to have_css('.page-item.active', text: '1')

      # Checkboxes should still be checked
      checkboxes = page.all('.bulk-action-checkbox input[type="checkbox"]').reject { |cb| cb[:id] == 'checkbox-all' }
      expect(checkboxes[0]).to be_checked
      expect(checkboxes[1]).to be_checked

      # Reload the page
      page.driver.browser.navigate.refresh

      # Selection should persist after reload
      expect(page).to have_css('[data-bulk-action-target="selectionText"]', visible: true)
      expect(find('[data-bulk-action-target="counter"]').text).to eq('2')

      # Clear selection via button
      click_link 'zrušit výběr'

      # Selection should be cleared
      expect(page).to have_css('[data-bulk-action-target="selectionText"]', visible: :hidden)
    end
  end

  describe 'Pagination & Layout' do
    # UL-015: Change Records Per Page
    it 'updates displayed items when changing per-page value' do
      visit '/admin/users'

      select '24', from: 'per_page'

      # Should show more items on the page
      expect(page).to have_content('22 záznamů')
    end

    # UL-016: Next Page Navigation
    it 'navigates to next page' do
      visit '/admin/users'

      within('.pagination') do
        click_link '→'
      end

      expect(page).to have_css('.page-item.active', text: '2')
    end

    # UL-017: Previous Page Navigation
    it 'navigates to previous page' do
      visit '/admin/users?fa_page=2'

      within('.pagination') do
        click_link '←'
      end

      expect(page).to have_css('.page-item.active', text: '1')
    end

    # UL-018: Specific Page Selection
    it 'navigates to specific page number' do
      create_list(:user, 40)  # Ensure enough for 3+ pages
      visit '/admin/users'

      within('.pagination') do
        click_link '3'
      end

      expect(page).to have_css('.page-item.active', text: '3')
    end
  end
end
