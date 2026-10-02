# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexiAdmin::Components::Shared::TabsComponent, type: :component do
  def render_tabs(**options)
    render_inline(described_class.new(id: 'order', **options)) do |tabs|
      tabs.with_tab(key: 'prehled', label: 'Přehled') { 'overview pane' }
      tabs.with_tab(key: 'kalkulace', label: 'Kalkulace', count: 3) { 'calculations pane' }
      yield tabs if block_given?
    end
  end

  context 'when a long show page is split into sections' do
    it 'renders one tab button per section, each wired to its own pane' do
      render_tabs

      expect(page).to have_css('button[role=tab][data-bs-target="#order-pane-prehled"]', text: 'Přehled')
      expect(page).to have_css('#order-pane-kalkulace[role=tabpanel]', text: 'calculations pane')
    end

    it 'renders every pane up front, so content behaves as it did on the single page' do
      render_tabs

      expect(page).to have_css('.tab-pane', count: 2, visible: :all)
      expect(page).to have_text('overview pane')
    end

    it 'shows a count badge only where the caller gave one, so empty sections are visible at a glance' do
      render_tabs

      expect(page).to have_css('#order-tab-kalkulace .badge', text: '3')
      expect(page).to have_no_css('#order-tab-prehled .badge')
    end
  end

  context 'when no tab is marked active' do
    it 'opens on the first tab, so the page never shows an empty content area' do
      render_tabs

      expect(page).to have_css('#order-tab-prehled.active[aria-selected=true]')
      expect(page).to have_css('#order-pane-prehled.show.active')
      expect(page).to have_no_css('#order-pane-kalkulace.active', visible: :all)
    end
  end

  context 'when the caller marks a tab active' do
    it 'opens on that tab instead of the first' do
      render_inline(described_class.new(id: 'order')) do |tabs|
        tabs.with_tab(key: 'prehled', label: 'Přehled') { 'a' }
        tabs.with_tab(key: 'zdv', label: 'ZDV', active: true) { 'b' }
      end

      expect(page).to have_css('#order-pane-zdv.show.active')
      expect(page).to have_no_css('#order-tab-prehled.active')
    end
  end

  context 'with URL-hash memory — a reload or shared link should reopen the same tab' do
    it 'wires the tabs Stimulus controller by default' do
      render_tabs

      expect(page).to have_css('.flexi-tabs[data-controller=tabs]')
      expect(page).to have_css('#order-tab-kalkulace[data-tabs-key-param=kalkulace]' \
                               '[data-action="shown.bs.tab->tabs#remember"]')
    end

    it 'leaves the URL alone when the caller opts out, e.g. for a second tab set on the same page' do
      render_tabs(remember: false)

      expect(page).to have_no_css('[data-controller=tabs]')
      expect(page).to have_no_css('[data-action*="tabs#remember"]')
    end
  end

  context 'when no tabs are given' do
    it 'renders nothing rather than an empty tab bar' do
      render_inline(described_class.new(id: 'empty'))

      expect(page).to have_no_css('.nav-tabs')
    end
  end
end
