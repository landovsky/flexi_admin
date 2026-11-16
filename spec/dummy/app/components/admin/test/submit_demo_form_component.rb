# frozen_string_literal: true

module Admin
  module Test
    # Mock form for the submit button states (lock / spinner / ✓ / ✕). The visitor picks how the
    # server answers, so every branch of submit_button_controller.js can be seen by hand.
    class SubmitDemoFormComponent < ViewComponent::Base
      include FlexiAdmin::Components::Resource::FormMixin

      OUTCOMES = [
        ['Uloží se (200, ✓)', 'ok'],
        ['Validační chyba (200 + hlavička error, formulář se překreslí, ✕)', 'validation'],
        ['Chyba serveru 422 (jen toast, formulář zůstane, ✕ podle HTTP)', 'http_422']
      ].freeze

      attr_reader :params_in, :error

      def initialize(params_in: {}, error: nil)
        @params_in = params_in
        @error = error
        @disabled = false
      end

      def call
        form(url: helpers.admin_test_submit_button_submit_path, method: :post, css_class: 'myForm section') do
          safe_join([
            (content_tag(:div, error, class: 'alert alert-danger') if error),
            text_field(:name, label: 'Název', value: params_in[:name] || 'Hřiště u lesa'),
            select_field(:outcome, label: 'Odpověď serveru', options: OUTCOMES, value: params_in[:outcome] || 'ok'),
            number_field(:delay, label: 'Zpoždění (s)', value: params_in[:delay] || 1.5, step: 0.5),
            submit('Uložit', cancel_button: false, icon: 'save')
          ].compact)
        end
      end

      def resource = nil
      def disabled = @disabled
    end
  end
end
