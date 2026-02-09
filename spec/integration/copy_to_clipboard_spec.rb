# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Copy to Clipboard for Disabled Fields', type: :feature, js: true do
  before do
    create(:user, :balicka)
  end

  describe 'DOM structure in disabled mode' do
    before { visit '/admin/test/form_fields?disabled=true' }

    it 'adds copy button to disabled text field' do
      within('[data-testid="text-basic"]') do
        wrapper = find('.copy-field-wrapper')
        expect(wrapper['data-controller']).to eq('copy-to-clipboard')

        input = wrapper.find('input[type="text"]')
        expect(input[:disabled]).to eq('true')

        btn = wrapper.find('.copy-field-btn', visible: :all)
        expect(btn['data-action']).to eq('click->copy-to-clipboard#copy')

        icon = btn.find('i', visible: :all)
        expect(icon[:class]).to include('bi-clipboard')
      end
    end

    it 'adds copy button to disabled number field' do
      within('[data-testid="number-basic"]') do
        expect(page).to have_css('.copy-field-wrapper[data-controller="copy-to-clipboard"]')
        expect(page).to have_css('.copy-field-btn', visible: :all)
      end
    end

    it 'adds copy button to disabled date field' do
      within('[data-testid="date-basic"]') do
        expect(page).to have_css('.copy-field-wrapper[data-controller="copy-to-clipboard"]')
        expect(page).to have_css('.copy-field-btn', visible: :all)
      end
    end

    it 'adds copy button to disabled datetime field' do
      within('[data-testid="datetime-basic"]') do
        expect(page).to have_css('.copy-field-wrapper[data-controller="copy-to-clipboard"]')
        expect(page).to have_css('.copy-field-btn', visible: :all)
      end
    end
  end

  describe 'no copy button in edit mode' do
    before { visit '/admin/test/form_fields' }

    it 'does not add copy wrapper to enabled text fields' do
      within('[data-testid="text-basic"]') do
        expect(page).not_to have_css('.copy-field-wrapper')
        expect(page).not_to have_css('.copy-field-btn', visible: :all)
      end
    end

    it 'does not add copy wrapper to individually disabled fields' do
      within('[data-testid="text-disabled"]') do
        input = find('input[type="text"]')
        expect(input[:disabled]).to eq('true')

        expect(page).not_to have_css('.copy-field-wrapper')
        expect(page).not_to have_css('.copy-field-btn', visible: :all)
      end
    end
  end

  describe 'copy button visibility' do
    before { visit '/admin/test/form_fields?disabled=true' }

    it 'copy button is hidden by default and visible on hover' do
      within('[data-testid="text-basic"]') do
        btn = find('.copy-field-btn', visible: :all)
        expect(btn.style('opacity')['opacity']).to eq('0')

        wrapper = find('.copy-field-wrapper')
        wrapper.hover

        expect(btn.style('opacity')['opacity']).to eq('1')
      end
    end
  end
end
