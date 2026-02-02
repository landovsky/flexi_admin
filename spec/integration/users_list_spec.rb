# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users List Page', type: :feature do
  before do
    # Create test data matching ui-test-cases.md scenarios
    create(:user, :balicka)
    create(:user, :effenberger)
    create_list(:user, 20)  # Create enough users for pagination
  end

  describe 'Search & Filter' do
    # UL-001: Search by Full Name
    it 'searches users by full name' do
      visit '/admin/users'

      fill_in 'jméno, email', with: 'Balická'
      # Wait for debounce or press enter
      find_field('jméno, email').native.send_keys(:return)

      expect(page).to have_content('Balická')
      expect(page).not_to have_content('Effenberger')
    end

    # UL-002: Search by Email
    it 'searches users by email' do
      visit '/admin/users'

      fill_in 'jméno, email', with: 'balicka@hristehrou.cz'
      find_field('jméno, email').native.send_keys(:return)

      expect(page).to have_content('balicka@hristehrou.cz')
      expect(page).to have_css('.user-row', count: 1)
    end

    # UL-003: Search by Partial Text
    it 'searches with partial text match' do
      visit '/admin/users'

      fill_in 'jméno, email', with: 'effen'
      find_field('jméno, email').native.send_keys(:return)

      expect(page).to have_content('Effenberger')
    end

    # UL-004: Filter by Role
    it 'filters users by role' do
      visit '/admin/users'

      select 'admin', from: 'Role'

      expect(page).to have_content('Balická')  # Admin user
      # Regular users should be filtered out
    end

    # UL-005: Clear Filters
    it 'clears all filters when clicking Zrušit' do
      visit '/admin/users'

      fill_in 'jméno, email', with: 'test'
      select 'admin', from: 'Role'

      click_button 'Zrušit'

      expect(find_field('jméno, email').value).to be_blank
      expect(page).to have_css('.user-row', minimum: 10)  # Shows all users
    end
  end

  describe 'Sorting' do
    # UL-006: Sort by Full Name
    it 'sorts users by full name', js: true do
      visit '/admin/users'

      click_link 'Celé jméno'

      # Check that users are sorted alphabetically
      user_names = page.all('.user-name').map(&:text)
      expect(user_names).to eq(user_names.sort)

      # Click again to toggle descending
      click_link 'Celé jméno'
      user_names = page.all('.user-name').map(&:text)
      expect(user_names).to eq(user_names.sort.reverse)
    end

    # UL-007: Sort by Email
    it 'sorts users by email' do
      visit '/admin/users'

      click_link 'Email'

      emails = page.all('.user-email').map(&:text)
      expect(emails).to eq(emails.sort)
    end
  end

  describe 'Selection & Bulk Actions' do
    # UL-010: Select All Records
    it 'selects all visible users when clicking header checkbox', js: true do
      visit '/admin/users'

      find('input[type="checkbox"][data-action*="bulk-action"]', match: :first).click

      checkboxes = page.all('input[type="checkbox"][data-bulk-action-target="checkbox"]')
      expect(checkboxes).to all(be_checked)
    end

    # UL-011: Select Individual Record
    it 'selects individual user row', js: true do
      visit '/admin/users'

      first_checkbox = page.all('input[type="checkbox"][data-bulk-action-target="checkbox"]').first
      first_checkbox.click

      expect(first_checkbox).to be_checked
    end

    # UL-012: Multi-selection
    it 'maintains selection of multiple users', js: true do
      visit '/admin/users'

      checkboxes = page.all('input[type="checkbox"][data-bulk-action-target="checkbox"]')
      checkboxes[0].click
      checkboxes[2].click
      checkboxes[4].click

      expect(checkboxes[0]).to be_checked
      expect(checkboxes[2]).to be_checked
      expect(checkboxes[4]).to be_checked
      expect(checkboxes[1]).not_to be_checked
    end

    # UL-013: Bulk Actions Availability
    it 'enables bulk actions dropdown when users are selected', js: true do
      visit '/admin/users'

      first_checkbox = page.all('input[type="checkbox"][data-bulk-action-target="checkbox"]').first
      first_checkbox.click

      # Bulk action button should be enabled
      click_button 'Akce'

      expect(page).to have_content('Delete')  # or other bulk actions
    end

    # UL-014: Bulk Actions Inactive
    it 'disables bulk actions when no users selected' do
      visit '/admin/users'

      bulk_action_button = find('button', text: 'Akce')

      # Should be disabled or show no actions available
      expect(bulk_action_button[:disabled]).to be_truthy
    end
  end

  describe 'Pagination & Layout' do
    # UL-015: Change Records Per Page
    it 'updates displayed items when changing per-page value', js: true do
      visit '/admin/users'

      select '32', from: 'per_page'

      # Should show more items
      expect(page).to have_css('.user-row', count: 22)  # All 22 users on one page
    end

    # UL-016: Next Page Navigation
    it 'navigates to next page' do
      create_list(:user, 40)  # Ensure multiple pages
      visit '/admin/users'

      click_link '>'  # Next button

      expect(current_url).to include('page=2')
    end

    # UL-017: Previous Page Navigation
    it 'navigates to previous page' do
      create_list(:user, 40)
      visit '/admin/users?page=2'

      click_link '<'  # Previous button

      expect(current_url).to include('page=1')
    end

    # UL-018: Specific Page Selection
    it 'navigates to specific page number' do
      create_list(:user, 60)
      visit '/admin/users'

      click_link '3'

      expect(current_url).to include('page=3')
    end

    # UL-019: Toggle Grid View
    it 'switches to grid layout', js: true do
      visit '/admin/users'

      click_button class: 'grid-view-toggle'

      expect(page).to have_css('.grid-view')
      expect(page).not_to have_css('.table-view')
    end

    # UL-020: Toggle List View
    it 'switches back to list/table layout', js: true do
      visit '/admin/users'

      click_button class: 'grid-view-toggle'
      click_button class: 'list-view-toggle'

      expect(page).to have_css('.table-view')
      expect(page).not_to have_css('.grid-view')
    end
  end
end
