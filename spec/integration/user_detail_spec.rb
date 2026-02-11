# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Detail Page', type: :feature, js: true do
  let(:user) { create(:user, full_name: 'Test User', email: 'test@example.com', role: 'user', user_type: 'internal') }

  describe 'Navigation & Layout' do
    # UD-001: Breadcrumb Navigation
    it 'navigates back to users list via breadcrumb' do
      visit "/admin/users/#{user.id}"

      within('nav.breadcrumb') do
        click_link 'Uživatel'
      end

      expect(page).to have_content('Uživatelé')
      expect(page).to have_css('flexi-table')
    end

    # UD-002: Back Link
    it 'returns to list page when clicking back button' do
      visit "/admin/users/#{user.id}"

      within('.header-actions') do
        click_link 'Back'
      end

      expect(page).to have_content('Uživatelé')
      expect(page).to have_css('flexi-table')
    end
  end

  describe 'Data Display & Interaction' do
    # UD-003: View Key Information
    it 'displays all read-only user information' do
      user.update!(last_sign_in_at: 10.minutes.ago)
      visit "/admin/users/#{user.id}"

      expect(page).to have_content(user.full_name)
      expect(page).to have_field('user[email]', with: user.email, disabled: true)
      expect(page).to have_content('Basic Information')
      expect(page).to have_content('Role & Type')
      expect(page).to have_content('Metadata')
    end

    # UD-004: Edit Text Fields (after enabling edit mode)
    it 'allows editing of user fields after clicking Edit' do
      visit "/admin/users/#{user.id}"

      # Fields start disabled
      expect(page).to have_field('user[full_name]', disabled: true)

      # Enable edit mode
      click_button 'Edit'

      # Fields should now be editable
      expect(page).to have_field('user[full_name]', disabled: false)

      fill_in 'user[full_name]', with: 'Updated Name'
      expect(page).to have_field('user[full_name]', with: 'Updated Name')
    end

    # UD-005: Change Role
    it 'changes user role via multi-button selector' do
      visit "/admin/users/#{user.id}"

      within('.role-selector') do
        click_button 'admin'
      end

      expect(page).to have_css('.role-selector .btn.active', text: 'admin')
    end

    # UD-006: Change Type
    it 'changes user type via multi-button selector' do
      visit "/admin/users/#{user.id}"

      within('.type-selector') do
        click_button 'external'
      end

      expect(page).to have_css('.type-selector .btn.active', text: 'external')
    end
  end

  describe 'Actions' do
    # UD-008: Edit Mode Toggle
    it 'enables and disables editing when clicking Edit/Cancel' do
      visit "/admin/users/#{user.id}"

      # Initially disabled
      expect(page).to have_field('user[full_name]', disabled: true)

      # Click Edit to enable
      click_button 'Edit'
      expect(page).to have_field('user[full_name]', disabled: false)
      expect(page).to have_button('Cancel')

      # Click Cancel to disable again
      click_button 'Cancel'
      expect(page).to have_field('user[full_name]', disabled: true)
      expect(page).to have_button('Edit')
    end

    # UD-009: Delete User
    it 'deletes user after confirmation and redirects to index' do
      user_id = user.id
      visit "/admin/users/#{user_id}"

      # Verify user exists before deletion
      expect(User.find_by(id: user_id)).not_to be_nil

      # Remove turbo confirm to bypass dialog, then submit via requestSubmit so Turbo processes it
      page.execute_script(<<~JS)
        var form = document.querySelector('form[action*="/admin/users/#{user_id}"][method="post"] input[name="_method"][value="delete"]').closest('form');
        delete form.dataset.turboConfirm;
        form.requestSubmit();
      JS

      # Wait for redirect to index page
      expect(page).to have_css('flexi-table', wait: 10)
      expect(page).to have_content('Uživatelé')

      # User should be deleted from the database
      expect(User.find_by(id: user_id)).to be_nil
    end
  end
end
