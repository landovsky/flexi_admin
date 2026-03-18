# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlexiAdmin::Components::Resources::GridView::CardComponent, type: :component do
  let(:user) { create(:user) }
  let(:context) { build_context(resource: user, resources: User.all, scope: 'users') }

  let(:title_element) do
    FlexiAdmin::Components::Resources::GridViewComponent::Element.new(
      :full_name,
      proc { |r| r.full_name },
      { formatter: proc { |v| v } }
    )
  end

  describe 'quick_action' do
    it 'renders the quick action content when provided' do
      quick_action = proc { |resource| "<a href='/users/#{resource.id}' class='btn btn-sm'>View</a>".html_safe }

      render_inline(described_class.new(user, title_element, nil, nil, nil, quick_action, context))

      expect(page).to have_css('.quick-action .btn', text: 'View')
    end

    it 'does not render quick action container when not provided' do
      render_inline(described_class.new(user, title_element, nil, nil, nil, nil, context))

      expect(page).not_to have_css('.quick-action')
    end
  end
end
