# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexiAdmin::Components::Nav::ThemeScriptComponent, type: :component do
  context 'the theme must be applied before first paint, or dark-mode users see a light flash' do
    it 'renders an inline script (not a deferred module) that sets data-bs-theme' do
      html = render_inline(described_class.new).to_html

      expect(html).to include('<script')
      expect(html).not_to include('type="module"')
      expect(html).to include('data-bs-theme')
    end
  end

  context 'users who never picked a theme' do
    it 'follow the OS setting by default' do
      expect(render_inline(described_class.new).to_html).to include('fallback = "auto"')
    end

    it 'can be pinned to light by the host app until they choose otherwise' do
      expect(render_inline(described_class.new(default: 'light')).to_html).to include('fallback = "light"')
    end

    it 'ignore an unknown default rather than writing it into the page' do
      expect(render_inline(described_class.new(default: 'neon')).to_html).to include('fallback = "auto"')
    end
  end
end
