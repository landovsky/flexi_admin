# frozen_string_literal: true

module FlexiAdmin::Components::Nav
  class BreadcrumbsComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::UrlHelper

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
        if idx.positive? && is_id?(segment)
          # For instance, use singularized model name for lookup, but display uses instance title
          model_class = infer_model_class(segments[idx - 1], segments[0..idx-2])
          record = model_class&.find_by(id: segment)
          label = record&.title if record.respond_to?(:title)
          label ||= record&.try(:name)
          label ||= "#{segments[idx - 1].singularize.camelize} ##{segment}"
          url += "/#{segment}"
        elsif !is_id?(segment)
          # For collection, use plural segment for display and I18n lookup
          plural_segment = segment
          model_class = infer_model_class(segment, segments[0..idx-1])
          label = breadcrumb_label(model_class, plural_segment)
          url += "/#{segment}"
        end

        crumbs << { label: label, url: url.dup }
      end
      crumbs
    end

    private

    def is_id?(segment)
      segment.match?(/\A\d+\z/) || segment.match?(/\A[\da-fA-F-]{36}\z/)
    end

    def breadcrumb_label(model_class, plural_segment)
      if model_class.is_a?(Class) && model_class.respond_to?(:breadcrumb_title)
        model_class.breadcrumb_title
      elsif model_class.is_a?(Class) && model_class.respond_to?(:model_name)
        I18n.t("activerecord.models.#{model_class.model_name.i18n_key}.few",
               default: model_class.model_name.human)
      elsif model_class.is_a?(Module)
        # For namespaces/modules, try to translate
        module_name = model_class.name.underscore
        I18n.t("activerecord.models.#{module_name}.few", default: module_name.humanize)
      else
        I18n.t("breadcrumbs.#{plural_segment}", default: plural_segment.titleize)
      end
    end

    def infer_model_class(segment, previous_segments = [])
      singular = segment.singularize
      candidates = [singular.camelize]
      if singular.include?('_')
        parts = singular.split('_')
        namespace = parts[0].camelize
        model = parts[1..-1].join('_').camelize
        candidates << "#{namespace}::#{model}"
      end
      # Try with previous segments as potential namespaces
      previous_segments.reverse.each do |prev|
        next if is_id?(prev)

        namespace = prev.singularize.camelize
        candidates << "#{namespace}::#{singular.camelize}"
      end
      candidates.each do |name|
        cls = name.safe_constantize
        return cls if cls
      end
      nil
    end
  end
end
