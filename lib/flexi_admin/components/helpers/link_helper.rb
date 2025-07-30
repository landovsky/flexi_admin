# frozen_string_literal: true

module FlexiAdmin::Components::Helpers::LinkHelper
  def navigate_to(title, resource)
    parent = context&.options&.dig(:parent)
    namespace = FlexiAdmin::Config.configuration.namespace
    if resource.is_a?(String)
      helpers.link_to title, resource, "data-turbo-frame": "_top"
    else
      path_segments = if parent.present? && parent.class != resource.class
                        namespace.present? ? [namespace.to_sym, parent, resource] : [parent, resource]
                      elsif namespace.present?
                        [namespace.to_sym, resource]
                      else
                        resource
                      end
      helpers.link_to title, helpers.polymorphic_path(path_segments), "data-turbo-frame": "_top"
    end
  rescue StandardError => e
    binding.pry if Rails.env.development?
  end
end
