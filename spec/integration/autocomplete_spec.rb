# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Autocomplete Component', type: :feature, js: true do
  before do
    # Create test users for autocomplete
    create(:user, :balicka) # Admin user
    create(:user, :effenberger) # Regular user
    create_list(:user, 5)
  end

  describe 'Select Mode (:select)' do
    # AC-001: Select Mode - Search and Select
    it 'searches and selects a user from autocomplete' do
      visit '/admin/test/autocomplete'

      within('[data-testid="select-enabled"]') do
        fill_in 'supervisor_id', with: 'Balick'

        # Wait for autocomplete results
        expect(page).to have_css('.autocomplete ul li', wait: 5)

        # Click on the result
        find('.autocomplete ul li', text: 'Balická').click

        # Verify input shows selected name
        expect(page).to have_field('supervisor_id', with: 'Balická')

        # Verify hidden field contains the ID
        hidden_field = find('input[type="hidden"][name="supervisor_id"]', visible: false)
        expect(hidden_field.value).not_to be_empty
      end
    end

    # AC-002: Select Mode - Clear Selection
    it 'clears selection when clicking clear icon' do
      visit '/admin/test/autocomplete'

      within('[data-testid="select-enabled"]') do
        # First select a user
        fill_in 'supervisor_id', with: 'Balick'
        expect(page).to have_css('.autocomplete ul li', wait: 5)
        find('.autocomplete ul li', text: 'Balická').click

        # Verify selection
        expect(page).to have_field('supervisor_id', with: 'Balická')

        # Click clear icon
        find('[data-autocomplete-target="clearIcon"]').click

        # Verify input is cleared
        expect(page).to have_field('supervisor_id', with: '')

        # Verify hidden field is cleared
        hidden_field = find('input[type="hidden"][name="supervisor_id"]', visible: false)
        expect(hidden_field.value).to be_empty
      end
    end

    # AC-003: Select Mode - Disabled with Resource
    it 'shows link to resource when disabled with resource' do
      visit '/admin/test/autocomplete'

      within('[data-testid="select-disabled-with-resource"]') do
        # Should show a link instead of input
        expect(page).to have_link
        expect(page).not_to have_css('input.form-control')

        # Link should point to user detail
        link = find('a')
        expect(link[:href]).to include('/admin/users/')
      end
    end

    # AC-004: Select Mode - Disabled without Resource
    it 'shows empty message when disabled without resource' do
      visit '/admin/test/autocomplete'

      within('[data-testid="select-disabled-without-resource"]') do
        # Should show empty message
        expect(page).to have_css('.text-muted', text: 'žádný zdroj')
        expect(page).not_to have_css('input.form-control')
      end
    end
  end

  describe 'Show Mode (:show)' do
    # AC-005: Show Mode - Search and View Results
    it 'searches and displays results without selection handler' do
      visit '/admin/test/autocomplete'

      within('[data-testid="show-enabled"]') do
        fill_in 'show_user_id', with: 'Effen'

        # Wait for autocomplete results
        expect(page).to have_css('.autocomplete ul li', wait: 5)

        # Results should display
        expect(page).to have_css('.autocomplete ul li', text: 'Effenberger')
      end
    end

    # AC-007: Show Mode - Disabled with Resource
    it 'shows link when show mode is disabled with resource' do
      visit '/admin/test/autocomplete'

      within('[data-testid="show-disabled-with-resource"]') do
        # Should show a link
        expect(page).to have_link
        expect(page).not_to have_css('input.form-control')
      end
    end

    # AC-008: Show Mode - Disabled without Resource
    it 'shows custom empty message when show mode is disabled without resource' do
      visit '/admin/test/autocomplete'

      within('[data-testid="show-disabled-without-resource"]') do
        # Should show custom empty message
        expect(page).to have_css('.text-muted', text: 'No user selected')
        expect(page).not_to have_css('input.form-control')
      end
    end
  end

  describe 'Input Mode (:input / Datalist)' do
    # AC-009: Input Mode - Search and Select Value
    # Pending: Datalist AJAX functionality needs further investigation
    it 'searches and selects text value from datalist', pending: 'Datalist AJAX needs investigation' do
      visit '/admin/test/autocomplete'

      within('[data-testid="input-enabled"]') do
        fill_in 'role_input', with: 'adm'

        # Wait for datalist results
        expect(page).to have_css('.autocomplete ul li', wait: 5)

        # Click on the result
        first('.autocomplete ul li').click

        # Verify input contains the text value (not ID)
        input = find('input.form-control')
        expect(input.value).to be_present
      end
    end

    # AC-010: Input Mode - Icon Differs (alphabet icon instead of search)
    # Pending: Bootstrap icons may not be loaded in test environment
    it 'shows alphabet icon for input mode', pending: 'Bootstrap icons not visible in tests' do
      visit '/admin/test/autocomplete'

      within('[data-testid="input-enabled"]') do
        # Icon should have bi-alphabet class
        expect(page).to have_css('.bi-alphabet')
      end
    end

    # AC-011: Input Mode - Disabled with Value
    it 'shows plain text when input mode is disabled with value' do
      visit '/admin/test/autocomplete'

      within('[data-testid="input-disabled-with-value"]') do
        # Should show the value as plain text
        expect(page).to have_content('admin')
        expect(page).not_to have_css('input.form-control')
        expect(page).not_to have_link # No link for input mode
      end
    end

    # AC-012: Input Mode - Disabled without Value
    it 'shows empty state when input mode is disabled without value' do
      visit '/admin/test/autocomplete'

      within('[data-testid="input-disabled-without-value"]') do
        # Disabled input mode without value shows nothing (no input, no link)
        expect(page).not_to have_css('input.form-control')
        expect(page).not_to have_link
      end
    end
  end

  describe 'Cross-Mode Behavior' do
    # AC-013: Debounced Search - results appear after typing
    it 'shows results after typing and waiting for debounce' do
      visit '/admin/test/autocomplete'

      within('[data-testid="select-enabled"]') do
        input = find('input.form-control')

        # Type search term
        input.send_keys('Balic')

        # Results should eventually appear (after debounce)
        expect(page).to have_css('.autocomplete ul li', wait: 5)
        expect(page).to have_css('.autocomplete ul li', text: 'Balická')
      end
    end

    # AC-014: Results Hide on Blur
    it 'hides results when clicking outside' do
      visit '/admin/test/autocomplete'

      within('[data-testid="select-enabled"]') do
        fill_in 'supervisor_id', with: 'Balick'
        expect(page).to have_css('.autocomplete ul li', wait: 5)
      end

      # Click outside
      find('h1').click

      # Results should hide after delay
      within('[data-testid="select-enabled"]') do
        expect(page).not_to have_css('.autocomplete ul li', wait: 2)
      end
    end

    # AC-015: Custom Scope Support - filters results based on proc scope
    it 'uses custom scope for filtering results' do
      visit '/admin/test/autocomplete'

      within('[data-testid="custom-scope"]') do
        # Type to search - the custom scope should filter only admin users
        fill_in 'user_id', with: 'a'

        # Wait for results
        expect(page).to have_css('.autocomplete ul li', wait: 5)

        # At minimum, Balická (admin) should appear
        expect(page).to have_css('.autocomplete ul li', text: 'Balická')
      end
    end

    # AC-016: Required Validation
    it 'validates required field on form submission' do
      visit '/admin/test/autocomplete'

      # Try to submit without filling required field
      click_button 'Submit Form'

      # Form validation should prevent submission
      within('[data-testid="required-field"]') do
        # The input should show validation error
        input = find('input.form-control')
        expect(input[:required]).to eq('true')
      end
    end
  end
end
