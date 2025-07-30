# frozen_string_literal: true

module FlexiAdmin::Components::Nav
  class BreadcrumbsComponent < FlexiAdmin::Components::BaseComponent

    attr_reader :path

    def initialize(path:)
      super()
      @path = path
    end

    def breadcrumbs
      segments = path.split("/").reject(&:blank?)
      return [] if segments.size <= 1

      crumbs = []
      url = ""
      segments.each_with_index do |segment, idx|
        if idx.positive? && (segment.match?(/\A\d+\z/) || segment.match?(/\A[\da-fA-F-]{36}\z/))
          # For instance, use singularized model name for lookup, but display uses instance title
          model_class_name = segments[idx - 1].singularize.camelize
          model_class = model_class_name.safe_constantize
          record = model_class&.find_by(id: segment)
          label = record&.title if record.respond_to?(:title)
          label ||= record&.try(:name)
          label ||= "#{model_class_name} ##{segment}"
          url += "/#{segment}"
          crumbs << { label: label, url: url.dup }
        elsif !segment.match?(/\A\d+\z/)
          # For collection, use plural segment for display and I18n lookup
          plural_segment = segment
          model_class_name = segment.singularize.camelize
          model_class = model_class_name.safe_constantize
          label = if model_class && model_class.respond_to?(:breadcrumb_title)
                    model_class.breadcrumb_title
                  elsif model_class
                    I18n.t("activerecord.models.#{model_class.model_name.i18n_key}.few",
                           default: model_class.model_name.human)
                  else
                    plural_segment.titleize
                  end
          url += "/#{segment}"
          crumbs << { label: label, url: url.dup }
        end
      end
      crumbs
    end
  end
end
