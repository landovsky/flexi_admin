# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Detail Page', type: :feature do
  let(:user) { create(:user, full_name: 'Test User', email: 'test@example.com') }

  describe 'Navigation & Layout' do
    # UD-001: Breadcrumb Navigation
    it 'navigates back to users list via breadcrumb' do
      visit "/admin/users/#{user.id}"

      within('.breadcrumb') do
        click_link 'Uživatel'
      end

      expect(current_path).to eq('/admin/users')
    end

    # UD-002: Back Link/Cancel
    it 'returns to list page when clicking back button' do
      visit "/admin/users/#{user.id}"

      click_link 'Back'  # or 'Zrušit'

      expect(current_path).to eq('/admin/users')
    end
  end

  describe 'Data Display & Interaction' do
    # UD-003: View Key Information
    it 'displays all read-only user information' do
      user.update!(created_at: 1.day.ago, updated_at: 1.hour.ago, last_sign_in_at: 10.minutes.ago)
      visit "/admin/users/#{user.id}"

      expect(page).to have_content('Created')
      expect(page).to have_content('Updated')
      expect(page).to have_content('Poslední přihlášení')
      expect(page).to have_content(user.full_name)
      expect(page).to have_content(user.email)
    end

    # UD-004: Edit Text Fields
    it 'allows editing of user fields' do
      visit "/admin/users/#{user.id}"

      fill_in 'Jméno a příjmení', with: 'Updated Name'
      fill_in 'Email', with: 'updated@example.com'
      fill_in 'Telefon', with: '+420123456789'
      fill_in 'Osobní číslo', with: 'PN123456'

      # Form should be in dirty state
      expect(page).to have_field('Jméno a příjmení', with: 'Updated Name')
      expect(page).to have_field('Email', with: 'updated@example.com')
    end

    # UD-005: Change Role
    it 'changes user role via multi-button selector', js: true do
      visit "/admin/users/#{user.id}"

      within('.role-selector') do
        click_button 'admin'
      end

      expect(page).to have_css('.role-selector .active', text: 'admin')
    end

    # UD-006: Change Type
    it 'changes user type via multi-button selector', js: true do
      visit "/admin/users/#{user.id}"

      within('.type-selector') do
        click_button 'external'
      end

      expect(page).to have_css('.type-selector .active', text: 'external')
    end
  end

  describe 'Actions' do
    # UD-007: Wait for Auto-Save / Save
    it 'persists changes after modification', js: true do
      visit "/admin/users/#{user.id}"

      fill_in 'Jméno a příjmení', with: 'Auto Saved Name'

      # Wait for auto-save or click explicit save button
      sleep 1  # Wait for auto-save debounce

      # Reload page to verify persistence
      visit "/admin/users/#{user.id}"

      expect(page).to have_field('Jméno a příjmení', with: 'Auto Saved Name')
    end

    # UD-008: Edit Mode Toggle
    it 'enables editing when clicking pencil icon' do
      visit "/admin/users/#{user.id}"

      click_button class: 'edit-icon'

      # Form fields should become editable
      expect(page).to have_field('Jméno a příjmení', disabled: false)
    end

    # UD-009: Delete User
    it 'shows confirmation dialog before deleting user', js: true do
      visit "/admin/users/#{user.id}"

      accept_confirm do
        click_button class: 'delete-icon'
      end

      # Should redirect to users list
      expect(current_path).to eq('/admin/users')
      # User should be deleted
      expect(User.find_by(id: user.id)).to be_nil
    end
  end
end
