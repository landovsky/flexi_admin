# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Form Fields Component', type: :feature, js: true do
  before do
    create(:user, :balicka)
  end

  describe 'Text Fields' do
    # FF-001: Text Field - Basic Input
    it 'accepts text input in text field' do
      visit '/admin/test/form_fields'

      within('[data-testid="text-basic"]') do
        input = find('input[type="text"]')
        expect(input).to be_present

        input.fill_in with: 'New Name'
        expect(input.value).to eq('New Name')
      end
    end

    # FF-002: Text Field - Disabled
    it 'shows disabled text field that cannot be edited' do
      visit '/admin/test/form_fields'

      within('[data-testid="text-disabled"]') do
        input = find('input[type="text"]')
        expect(input[:disabled]).to eq('true')
        expect(input.value).to eq('Balická')
      end
    end

    # FF-003: Text Field - Required
    it 'shows asterisk on required text field label' do
      visit '/admin/test/form_fields'

      within('[data-testid="text-required"]') do
        label = find('label')
        expect(label.text).to include('*')

        input = find('input[type="text"]')
        expect(input[:required]).to eq('true')
      end
    end

    # FF-004: Text Field - Validation Error
    it 'shows validation error on invalid text field' do
      visit '/admin/test/form_fields'

      within('[data-testid="text-validation-error"]') do
        input = find('input[type="text"]')
        expect(input[:class]).to include('is-invalid')
        expect(page).to have_css('.invalid-feedback')
      end
    end

    # FF-005: Text Field - Proc Value
    it 'evaluates proc for text field value' do
      visit '/admin/test/form_fields'

      within('[data-testid="text-proc-value"]') do
        input = find('input[type="text"]')
        expect(input.value).to include('Computed:')
        expect(input.value).to include('Balická')
      end
    end
  end

  describe 'Number Fields' do
    # FF-006: Number Field - Basic Input
    it 'accepts numeric input with default step' do
      visit '/admin/test/form_fields'

      within('[data-testid="number-basic"]') do
        input = find('input[type="number"]')
        expect(input[:step]).to eq('0.01')
        expect(input.value).to eq('100.5')
      end
    end

    # FF-007: Number Field - Custom Step
    it 'uses custom step for number field' do
      visit '/admin/test/form_fields'

      within('[data-testid="number-custom-step"]') do
        input = find('input[type="number"]')
        expect(input[:step]).to eq('1')
      end
    end

    # FF-008: Number Field - Disabled
    it 'shows disabled number field' do
      visit '/admin/test/form_fields'

      within('[data-testid="number-disabled"]') do
        input = find('input[type="number"]')
        expect(input[:disabled]).to eq('true')
      end
    end
  end

  describe 'Checkbox Fields' do
    # FF-009/FF-011: Checkbox - Unchecked State
    it 'renders unchecked checkbox with toggle interaction' do
      visit '/admin/test/form_fields'

      within('[data-testid="checkbox-unchecked"]') do
        checkbox = find('input[type="checkbox"]')
        expect(checkbox).not_to be_checked

        # Test toggle interaction
        checkbox.click
        expect(checkbox).to be_checked
      end
    end

    # FF-010: Checkbox - Checked State
    it 'renders pre-checked checkbox' do
      visit '/admin/test/form_fields'

      within('[data-testid="checkbox-checked"]') do
        checkbox = find('input[type="checkbox"]')
        expect(checkbox).to be_checked
      end
    end

    # FF-012: Checkbox - Disabled
    it 'shows disabled checkbox that cannot be clicked' do
      visit '/admin/test/form_fields'

      within('[data-testid="checkbox-disabled"]') do
        checkbox = find('input[type="checkbox"]')
        expect(checkbox[:disabled]).to eq('true')
        expect(checkbox).to be_checked
      end
    end

    # FF-013: Checkbox - Proc Value
    it 'evaluates proc for checkbox checked state' do
      visit '/admin/test/form_fields'

      within('[data-testid="checkbox-proc"]') do
        checkbox = find('input[type="checkbox"]')
        # Proc checks if user.full_name.present? which should be true
        expect(checkbox).to be_checked
      end
    end
  end

  describe 'Select Fields' do
    # FF-014: Select - Basic Selection
    it 'allows selecting option from dropdown' do
      visit '/admin/test/form_fields'

      within('[data-testid="select-basic"]') do
        select = find('select')
        expect(select).to be_present

        select.find('option[value="admin"]').select_option
        expect(select.value).to eq('admin')
      end
    end

    # FF-015: Select - Pre-selected Value
    it 'shows pre-selected value in select' do
      visit '/admin/test/form_fields'

      within('[data-testid="select-preselected"]') do
        select = find('select')
        expect(select.value).to eq('admin')
      end
    end

    # FF-016: Select - Disabled
    it 'shows disabled select that cannot be changed' do
      visit '/admin/test/form_fields'

      within('[data-testid="select-disabled"]') do
        select = find('select')
        expect(select[:disabled]).to eq('true')
      end
    end

    # FF-017: Select - Required
    it 'shows asterisk on required select label' do
      visit '/admin/test/form_fields'

      within('[data-testid="select-required"]') do
        label = find('label')
        expect(label.text).to include('*')

        select = find('select')
        expect(select[:required]).to eq('true')
      end
    end
  end

  describe 'Button Select Fields' do
    # FF-019/FF-020: Button Select - Click to Select / Single Selection
    it 'allows clicking buttons to select and maintains single selection' do
      visit '/admin/test/form_fields'

      within('[data-testid="button-select-basic"]') do
        # Find buttons
        admin_btn = find('button', text: 'Admin')
        user_btn = find('button', text: 'User')

        # Click admin
        admin_btn.click
        expect(admin_btn[:class]).to include('selected')

        # Click user - admin should deselect
        user_btn.click
        expect(user_btn[:class]).to include('selected')
        expect(admin_btn[:class]).not_to include('selected')
      end
    end

    # FF-021: Button Select - Pre-selected Value
    it 'has pre-selected value in hidden input' do
      visit '/admin/test/form_fields'

      within('[data-testid="button-select-preselected"]') do
        # The hidden input contains the pre-selected value
        hidden_input = find('input[type="hidden"]', visible: false)
        expect(hidden_input.value).to eq('admin')
      end
    end

    # FF-022: Button Select - Disabled
    it 'shows disabled button select' do
      visit '/admin/test/form_fields'

      within('[data-testid="button-select-disabled"]') do
        # Disabled mode shows single button with value
        button = find('button')
        expect(button[:disabled]).to eq('true')
      end
    end
  end

  describe 'Date Fields' do
    # FF-024/FF-025: Date Field - Selection and Manual Entry
    it 'shows date field with date value' do
      visit '/admin/test/form_fields'

      within('[data-testid="date-basic"]') do
        input = find('input[type="date"]')
        expect(input.value).to eq(Date.today.to_s)
        expect(input[:style]).to include('max-width: 180px')
      end
    end

    # FF-026: Date Field - Disabled
    it 'shows disabled date field' do
      visit '/admin/test/form_fields'

      within('[data-testid="date-disabled"]') do
        input = find('input[type="date"]')
        expect(input[:disabled]).to eq('true')
      end
    end
  end

  describe 'Datetime Fields' do
    # FF-027: Datetime Field - Selection
    it 'shows datetime field with datetime value' do
      visit '/admin/test/form_fields'

      within('[data-testid="datetime-basic"]') do
        input = find('input[type="datetime"]') rescue find('input[type="datetime-local"]')
        expect(input.value).to be_present
      end
    end

    # FF-028: Datetime Field - Disabled
    it 'shows disabled datetime field' do
      visit '/admin/test/form_fields'

      within('[data-testid="datetime-disabled"]') do
        input = find('input[type="datetime"]') rescue find('input[type="datetime-local"]')
        expect(input[:disabled]).to eq('true')
      end
    end
  end

  describe 'Text Area Fields' do
    # FF-029: Text Area - Multi-line Input
    it 'shows textarea with multi-line content' do
      visit '/admin/test/form_fields'

      within('[data-testid="textarea-basic"]') do
        textarea = find('textarea')
        expect(textarea.value).to include('Line 1')
        expect(textarea.value).to include('Line 2')
      end
    end

    # FF-030: Text Area - Disabled
    it 'shows disabled textarea' do
      visit '/admin/test/form_fields'

      within('[data-testid="textarea-disabled"]') do
        textarea = find('textarea')
        expect(textarea[:disabled]).to eq('true')
      end
    end
  end

  describe 'Inline Fields' do
    # FF-037: Inline Fields
    it 'renders multiple fields side-by-side' do
      visit '/admin/test/form_fields'

      within('[data-testid="inline-example"]') do
        expect(page).to have_css('.inline-field-wrapper')

        first_input = find('input[name="first_name"]')
        last_input = find('input[name="last_name"]')

        expect(first_input.value).to eq('John')
        expect(last_input.value).to eq('Doe')
      end
    end
  end

  describe 'Form Utilities' do
    # FF-038: Header
    it 'renders section headers with description' do
      visit '/admin/test/form_fields'

      within('[data-testid="text-fields"]') do
        expect(page).to have_css('.header', text: 'Text Fields')
        expect(page).to have_css('.description', text: 'Standard single-line text inputs')
      end
    end

    # FF-039: Submit Button
    it 'renders submit button' do
      visit '/admin/test/form_fields'

      within('[data-testid="submit-basic"]') do
        submit = find('input[type="submit"]')
        expect(submit.value).to include('FF-039')
        expect(submit[:class]).to include('btn-primary')
      end
    end

    # FF-040: Submit with Cancel
    it 'renders submit button with cancel button' do
      visit '/admin/test/form_fields'

      within('[data-testid="submit-with-cancel"]') do
        expect(page).to have_css('input[type="submit"]')
        expect(page).to have_css('button', text: 'Zrušit')
      end
    end

    # FF-041: Submit Disabled
    it 'disables submit button in disabled mode' do
      visit '/admin/test/form_fields?disabled=true'

      within('[data-testid="submit-basic"]') do
        submit = find('input[type="submit"]')
        expect(submit[:disabled]).to eq('true')
      end
    end
  end

  describe 'Disabled Form Mode' do
    it 'disables all form fields when disabled parameter is true' do
      visit '/admin/test/form_fields?disabled=true'

      # Check various fields are disabled
      within('[data-testid="text-basic"]') do
        input = find('input[type="text"]')
        expect(input[:disabled]).to eq('true')
      end

      within('[data-testid="select-basic"]') do
        select = find('select')
        expect(select[:disabled]).to eq('true')
      end

      within('[data-testid="checkbox-unchecked"]') do
        checkbox = find('input[type="checkbox"]')
        expect(checkbox[:disabled]).to eq('true')
      end
    end
  end
end
