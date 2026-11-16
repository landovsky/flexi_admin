# frozen_string_literal: true

require 'rails_helper'

# Submit buttons lock while saving, spin, then show ✓ / ✕ until the form is touched
# (submit_button_controller.js). Exercised on the mock pages: /admin/test/submit_button (form)
# and Uživatelé → Akce → Test submitu (bulk-action modal).
RSpec.describe 'Submit button states', type: :feature, js: true do
  let(:button) { find('button[data-controller="submit-button"]') }

  def choose_outcome(label, delay: '1')
    select label, from: 'outcome'
    fill_in 'delay', with: delay
  end

  context 'an impatient double-click on Uložit' do
    it 'sends one request, because the button locks on the first click' do
      visit '/admin/test/submit_button'
      choose_outcome 'Uloží se (200, ✓)'

      page.execute_script(<<~JS)
        const b = document.querySelector('button[data-controller="submit-button"]');
        b.click(); b.click(); b.form.requestSubmit();
      JS

      expect(page).to have_css('button[data-submit-state="pending"][disabled] .spinner-border')
      expect(page).to have_css('button[data-submit-state="success"]')
      expect(find('#submit-count').text).to eq('1')
    end
  end

  context 'a successful save' do
    it 'replaces the spinner with a checkmark on the re-rendered form' do
      visit '/admin/test/submit_button'
      choose_outcome 'Uloží se (200, ✓)', delay: '0'

      button.click

      expect(page).to have_css('button.btn-success[data-submit-state="success"] .bi-check-lg')
    end
  end

  context 'a validation failure, which the gem answers with 200 and a re-rendered form' do
    it 'shows a cross, not a checkmark, because the server header says error' do
      visit '/admin/test/submit_button'
      choose_outcome 'Validační chyba (200 + hlavička error, formulář se překreslí, ✕)', delay: '0'

      button.click

      expect(page).to have_css('.alert-danger', text: 'Název je obsazený')
      expect(page).to have_css('button.btn-danger[data-submit-state="error"] .bi-x-lg')
    end

    it 'clears the cross once the user edits a field, since the result no longer describes the form' do
      visit '/admin/test/submit_button'
      choose_outcome 'Validační chyba (200 + hlavička error, formulář se překreslí, ✕)', delay: '0'
      button.click
      expect(page).to have_css('button[data-submit-state="error"]')

      fill_in 'name', with: 'Jiný název'

      expect(page).to have_css('button.btn-primary[data-submit-state="idle"] .bi-save')
    end
  end

  context 'a 422 without the header (host action outside ResourcesController)' do
    it 'falls back to the HTTP status and shows a cross on the form that stayed in place' do
      visit '/admin/test/submit_button'
      choose_outcome 'Chyba serveru 422 (jen toast, formulář zůstane, ✕ podle HTTP)', delay: '0'

      button.click

      expect(page).to have_css('button[data-submit-state="error"]:not([disabled])')
    end
  end

  context 'the bulk-action modal, whose "Spustit" sits outside the form' do
    before do
      create_list(:user, 2)
      visit '/admin/users'
      within('.dropdown') do
        click_button 'Akce'
        click_button 'Test submitu'
      end
      expect(page).to have_css('.modal.show')
    end

    it 'locks "Spustit" while the action runs, so a double-click cannot run it twice' do
      within('.modal') do
        fill_in 'demo_delay', with: '1.5'
        click_button 'Spustit'
        expect(page).to have_css('button[data-submit-state="pending"][disabled]', text: 'Spustit')
      end
    end

    it 'shows a cross and keeps the modal open when the server answers 422' do
      within('.modal') do
        select 'HTTP 422 (✕, modal zůstane otevřený)', from: 'demo_outcome'
        fill_in 'demo_delay', with: '0'
        click_button 'Spustit'
        expect(page).to have_css('button[data-submit-state="error"]', text: 'Spustit')
      end
      expect(page).to have_css('.modal.show')
    end
  end
end
