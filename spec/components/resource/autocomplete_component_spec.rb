# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexiAdmin::Components::Resource::AutocompleteComponent, type: :component do
  let(:user) { create(:user, full_name: 'Jane Example') }

  describe 'action: :input' do
    it 'renders a textarea with shared autocomplete wiring and no hidden resource id field' do
      render_inline(
        described_class.new(
          user,
          scope: :users,
          action: :input,
          name: 'user_id',
          fields: [:full_name]
        )
      )

      expect(page).to have_css('.autocomplete[data-controller="autocomplete"]')
      expect(page).to have_css('textarea.form-control.expandable-field[name="user_id"][rows="1"]')
      expect(page).to have_css('textarea[data-controller="expandable-field"]', visible: false)
      expect(page).to have_css('textarea[data-field-type="text"]', visible: false)
      expect(page).to have_css('textarea[data-autocomplete-target="input"]', visible: false)
      expect(page).to have_css('textarea[data-autocomplete-search-path*="ac_action=input"]', visible: false)
      expect(page).to have_css('textarea[data-action*="input->expandable-field#resize"]', visible: false)
      expect(page).not_to have_css('input[type="hidden"][data-autocomplete-target="resourceId"]')
    end

    it 'renders disabled input mode as legacy plain text by default even when a resource is present' do
      render_inline(
        described_class.new(
          user,
          scope: :users,
          action: :input,
          disabled: true,
          value: 'Stored freeform value'
        )
      )

      expect(page).to have_text('Stored freeform value')
      expect(page).not_to have_css('a')
    end

    it 'keeps disabled input mode blank by default when no value is present' do
      render_inline(
        described_class.new(
          user,
          scope: :users,
          action: :input,
          disabled: true
        )
      )

      expect(page).not_to have_css('a')
      expect(page).not_to have_css('.text-muted')
      expect(page.text.strip).to eq('')
    end

    it 'renders a disabled resource link only when explicitly opted in' do
      render_inline(
        described_class.new(
          user,
          scope: :users,
          action: :input,
          disabled: true,
          disabled_display: :link_if_resource,
          value: 'Open Jane'
        )
      )

      expect(page).to have_link('Open Jane', href: "/admin/users/#{user.id}")
    end
  end
end
