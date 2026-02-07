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
