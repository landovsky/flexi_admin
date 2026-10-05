# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Color theme', type: :feature, js: true do
  def theme
    page.evaluate_script('document.documentElement.getAttribute("data-bs-theme")')
  end

  before do
    visit '/admin/users'
    page.execute_script("localStorage.removeItem('flexi-admin-theme')")
  end

  context 'the toggle cycles auto → light → dark and the choice must survive navigation' do
    it 'switches to dark and keeps it after a reload' do
      visit '/admin/users'
      toggle = find('.flexi-theme-toggle')

      toggle.click # auto -> light
      expect(toggle).to have_text('Light')
      expect(theme).to eq('light')

      toggle.click # light -> dark
      expect(toggle).to have_text('Dark')
      expect(theme).to eq('dark')

      page.driver.browser.navigate.refresh
      expect(find('.flexi-theme-toggle')).to have_text('Dark')
      expect(theme).to eq('dark')
    end
  end

  context 'dark tokens must actually reach the page, not just the attribute' do
    it 'paints the body with the dark background token' do
      page.execute_script("localStorage.setItem('flexi-admin-theme', 'dark')")
      visit '/admin/users'

      bg = page.evaluate_script('getComputedStyle(document.body).backgroundColor')
      expect(bg).to eq('rgb(17, 17, 20)')
    end
  end
end
