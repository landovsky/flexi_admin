# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FormMixin#submit Cancel button', type: :component do
  let(:component_class) do
    Class.new(FlexiAdmin::Components::Resource::FormComponent) do
      attr_accessor :submit_options

      def self.name = 'CancelOnlyComponent'

      def call
        submit('Uložit', **submit_options)
      end
    end
  end

  def render_submit(resource, **submit_options)
    component = component_class.new(resource, disabled: false)
    component.submit_options = submit_options
    render_inline(component)
  end

  context 'editing a saved record' do
    it 'swaps the form back to read-only in place, as before' do
      user = create(:user)
      render_submit(user)

      expect(page).to have_css("button[data-action='click->form#disable']" \
                               "[data-form-resource-path-value*='/admin/users/#{user.id}/edit']", text: 'Zrušit')
    end
  end

  context 'creating a record (new form, or its redraw after a failed validation): no edit path exists yet' do
    it 'leaves for the list instead of asking for an edit path, which used to crash the render' do
      render_submit(User.new)

      expect(page).to have_css("a.btn[href='/admin/users']", text: 'Zrušit')
      expect(page).to have_no_css('[data-controller=form]')
    end

    it 'is inert while the form is disabled, like the button variant, so Cancel cannot leave mid-submit' do
      component = component_class.new(User.new, disabled: true)
      component.submit_options = {}
      render_inline(component)

      expect(page).to have_css("a.btn.disabled[aria-disabled='true'][tabindex='-1']", text: 'Zrušit')
      expect(page).to have_no_css('a[href]', text: 'Zrušit')
    end

    it 'still honours a cancel_button_url the host gave (hriste sends inspections back to the playground)' do
      render_submit(User.new, cancel_button_url: '/admin/comments')

      expect(page).to have_css("button[data-form-resource-path-value='/admin/comments']", text: 'Zrušit')
    end

    it 'drops Cancel when the resource has no list route, rather than failing the whole form' do
      component = component_class.new(User.new, disabled: false)
      component.submit_options = {}
      allow(component).to receive(:resources_path).and_raise(NoMethodError)
      render_inline(component)

      expect(page).to have_button('Uložit')
      expect(page).to have_no_text('Zrušit')
    end
  end
end
