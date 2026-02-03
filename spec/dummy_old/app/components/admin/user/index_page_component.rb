# frozen_string_literal: true

module Admin
  module User
    class IndexPageComponent < FlexiAdmin::Components::Resources::IndexPageComponent
      def initialize(resources, context_params:, scope:)
        super(
          resources,
          context_params: context_params,
          scope: scope,
          title: 'Uživatelé',
          show_search: true
        )
      end

      def before_render
        # Add search slot
        with_search do
          helpers.tag.div(class: 'search-field') do
            helpers.text_field_tag('search',
              context_params.params[:search],
              placeholder: 'jméno, email',
              class: 'form-control'
            )
          end
        end

        # Add filter slot
        filter_options = {
          role: ::User.distinct.pluck(:role).compact.map { |r| [r.titleize, r] }
        }

        with_filter do
          FlexiAdmin::Components::Resource::FilterComponent.new(
            filter_options: filter_options,
            params: context_params.params,
            field_labels: { role: 'Role' }
          )
        end
      end
    end
  end
end
