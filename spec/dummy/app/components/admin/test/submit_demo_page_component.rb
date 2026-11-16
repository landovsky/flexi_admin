# frozen_string_literal: true

module Admin
  module Test
    class SubmitDemoPageComponent < ViewComponent::Base
      def call
        safe_join([
          content_tag(:h1, 'Submit button states'),
          content_tag(:p, class: 'text-muted') do
            'Klikněte rychle dvakrát: odejde jen jeden požadavek (počítadlo níže). Během ukládání se točí spinner, ' \
              'pak ✓ nebo ✕. Výsledek zmizí, jakmile změníte libovolné pole. Modal: Uživatelé → Akce → Test submitu.'
          end,
          content_tag(:p) { safe_join(['Odeslaných požadavků: ', content_tag(:strong, '0', id: 'submit-count')]) },
          render(SubmitDemoFormComponent.new)
        ])
      end
    end
  end
end
