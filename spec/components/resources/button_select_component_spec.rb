# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexiAdmin::Components::Resource::ButtonSelectComponent, type: :component do
  let(:user) { create(:user, role: 'admin') }
  let(:options) { %w[admin internal external] }

  describe 'without labels' do
    it 'renders buttons with raw option values' do
      render_inline(described_class.new(user, :role, options, form: nil))

      options.each do |opt|
        expect(page).to have_button(opt)
      end
    end

    it 'sets data-value to the raw option value' do
      render_inline(described_class.new(user, :role, options, form: nil))

      options.each do |opt|
        expect(page).to have_css("button[data-value='#{opt}']", text: opt)
      end
    end
  end

  describe 'with labels' do
    let(:labels) { { 'admin' => 'Administrátor', 'internal' => 'Interní', 'external' => 'Externí' } }

    it 'renders buttons with translated label text' do
      render_inline(described_class.new(user, :role, options, form: nil, labels:))

      expect(page).to have_button('Administrátor')
      expect(page).to have_button('Interní')
      expect(page).to have_button('Externí')
    end

    it 'keeps raw option values in data-value' do
      render_inline(described_class.new(user, :role, options, form: nil, labels:))

      expect(page).to have_css("button[data-value='admin']", text: 'Administrátor')
      expect(page).to have_css("button[data-value='internal']", text: 'Interní')
    end

    it 'does not render raw values as button text' do
      render_inline(described_class.new(user, :role, options, form: nil, labels:))

      expect(page).to have_no_button('admin')
      expect(page).to have_no_button('internal')
    end
  end

  describe 'with symbol-keyed labels' do
    let(:labels) { { admin: 'Administrátor', internal: 'Interní' } }

    it 'resolves string options against symbol-keyed labels' do
      render_inline(described_class.new(user, :role, options, form: nil, labels:))

      expect(page).to have_css("button[data-value='admin']", text: 'Administrátor')
      expect(page).to have_css("button[data-value='internal']", text: 'Interní')
    end

    it 'falls back to raw value for unmapped options' do
      render_inline(described_class.new(user, :role, options, form: nil, labels:))

      expect(page).to have_css("button[data-value='external']", text: 'external')
    end
  end

  describe 'disabled state' do
    it 'shows raw value when no labels provided' do
      render_inline(described_class.new(user, :role, options, form: nil, disabled: true, value: 'admin'))

      expect(page).to have_button('admin', disabled: true)
    end

    it 'shows translated label when labels provided' do
      labels = { 'admin' => 'Administrátor' }
      render_inline(described_class.new(user, :role, options, form: nil, disabled: true, value: 'admin', labels:))

      expect(page).to have_button('Administrátor', disabled: true)
      expect(page).to have_no_button('admin', disabled: true)
    end

    it 'shows dash when value is nil' do
      render_inline(described_class.new(user, :role, options, form: nil, disabled: true, value: nil))

      expect(page).to have_button('-', disabled: true)
    end
  end

  describe '#label_for' do
    it 'returns mapped label' do
      component = described_class.new(user, :role, options, form: nil, labels: { 'admin' => 'Administrátor' })

      expect(component.label_for('admin')).to eq('Administrátor')
    end

    it 'returns raw option when no label defined' do
      component = described_class.new(user, :role, options, form: nil, labels: { 'admin' => 'Administrátor' })

      expect(component.label_for('external')).to eq('external')
    end

    it 'returns raw option when labels is empty' do
      component = described_class.new(user, :role, options, form: nil)

      expect(component.label_for('admin')).to eq('admin')
    end
  end
end
