# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FormMixin#submit', type: :component do
  # Smallest host of the mixin: a persisted user (Cancel needs an edit path) and just the button.
  let(:component_class) do
    Class.new(FlexiAdmin::Components::Resource::FormComponent) do
      attr_accessor :submit_options

      def self.name = 'SubmitOnlyComponent'

      def call
        submit('Uložit', cancel_button: false, **submit_options)
      end
    end
  end

  def render_submit(**submit_options)
    component = component_class.new(create(:user), disabled: false)
    component.submit_options = submit_options
    render_inline(component)
  end

  context 'with submit states on (the default)' do
    it 'renders a <button> so the spinner and ✓ / ✕ can sit in front of the label' do
      render_submit

      expect(page).to have_css('button[type=submit][data-controller="submit-button"]', text: 'Uložit')
      expect(page).to have_css('button [data-submit-button-target="indicator"]')
    end

    it 'keeps name=commit / value=label, so hosts reading params[:commit] see no difference' do
      render_submit

      expect(page).to have_css('button[name="commit"][value="Uložit"]')
    end

    it 'keeps a given icon in the indicator slot, where it is restored once a result clears' do
      render_submit(icon: 'save')

      expect(page).to have_css('[data-submit-button-target="indicator"] i.bi-save')
    end
  end

  context 'when a host opts out (selectors on input[type=submit], own JS on the button)' do
    it 'renders the legacy <input type="submit"> for a single call' do
      render_submit(submit_state: false)

      expect(page).to have_css('input[type=submit][value="Uložit"]')
      expect(page).to have_no_css('[data-controller="submit-button"]')
    end

    it 'renders the legacy markup everywhere when config.submit_button_states is false' do
      FlexiAdmin::Config.configuration.submit_button_states = false
      render_submit

      expect(page).to have_css('input[type=submit]')
    ensure
      FlexiAdmin::Config.configuration.submit_button_states = true
    end
  end
end
