# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexiAdmin::Components::Resources::PaginationComponent, type: :component do
  let(:user) { create(:user) }
  let(:users) { create_list(:user, 50) }

  let(:context) do
    build_context(
      resource: user,
      resources: users,
      scope: 'users',
      page: 2,
      per_page: 16
    )
  end

  describe 'rendering pagination controls' do
    it 'renders pagination component' do
      render_inline(described_class.new(context: context))

      expect(page).to have_css('.pagination')
    end

    it 'displays current page information' do
      render_inline(described_class.new(context: context))

      # Should show page 2 of total pages
      expect(page).to have_css('.page-item.active', text: '2')
    end

    it 'renders previous and next links' do
      render_inline(described_class.new(context: context))

      expect(page).to have_css('a', text: '<')  # Previous
      expect(page).to have_css('a', text: '>')  # Next
    end

    it 'includes per-page selector' do
      render_inline(described_class.new(context: context))

      expect(page).to have_select(with_options: ['16', '32', '64'])
    end
  end

  describe 'pagination state' do
    it 'marks current page as active' do
      render_inline(described_class.new(context: context))

      active_page = page.find('.page-item.active')
      expect(active_page).to have_text('2')
    end

    it 'disables previous link on first page' do
      first_page_context = build_context(
        resource: user,
        resources: users,
        scope: 'users',
        page: 1,
        per_page: 16
      )

      render_inline(described_class.new(context: first_page_context))

      expect(page).to have_css('.page-item.disabled', text: '<')
    end
  end
end
