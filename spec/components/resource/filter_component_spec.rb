# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexiAdmin::Components::Resource::FilterComponent, type: :component do
  let(:filter_options) do
    {
      status: [%w[active Aktivní], %w[inactive Neaktivní]],
      roles: { options: [%w[admin Admin], %w[editor Editor]], multiple: true }
    }
  end

  def render_filters(params: {})
    render_inline(described_class.new(filter_options: filter_options, params: params,
                                      field_labels: { status: 'Stav', roles: 'Role' }))
  end

  context 'a pick-one filter sits in the same bar as dropdown-button (multiple) filters' do
    it 'puts its label inside the control as a prefix so the select is not pushed down out of line' do
      render_filters

      expect(page).to have_css('.input-group > label.input-group-text + select[name="status"]')
      expect(page).to have_css('.input-group > label.input-group-text', text: 'Stav')
      expect(page).not_to have_css('label.form-label')
    end

    it 'keeps the prefix label tied to its select so screen readers still announce "Stav"' do
      render_filters

      select_id = page.find('select[name="status"]')[:id]
      expect(page).to have_css("label.input-group-text[for='#{select_id}']")
    end

    it 'stays a single select — status is pick-one, not a checkbox dropdown' do
      render_filters

      expect(page).not_to have_css('select[name="status"][multiple]')
      expect(page).not_to have_css('input[type=checkbox][name="status[]"]')
    end
  end

  context 'a filter value is already applied' do
    it 'preselects it and marks the select active so the user sees the list is narrowed' do
      # applied filters also render "remove" badges, which build URLs off the current request
      with_request_url('/admin/users') { render_filters(params: { status: 'inactive' }) }

      expect(page).to have_css('select.form-select.is-active[name="status"] option[selected][value="inactive"]')
    end
  end

  context 'multiple filters are unaffected by the single-select layout' do
    it 'still renders them as a dropdown button with the label inside' do
      render_filters

      expect(page).to have_css('button.dropdown-toggle', text: 'Role')
      expect(page).to have_css('input[type=checkbox][name="roles[]"]', count: 2)
    end
  end
end
