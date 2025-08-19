# frozen_string_literal: true

module FlexiAdmin::Components::Helpers::LinkHelper
  def navigate_to(title, resource)
    parent = context&.options&.dig(:parent) || parent_from_params
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

      result_path = begin
        helpers.polymorphic_path(path_segments)
      rescue NoMethodError
        without_parent = path_segments.without(parent)
        helpers.polymorphic_path(without_parent.empty? ? path_segments : without_parent)
      end

      helpers.link_to title, result_path, "data-turbo-frame": "_top"
    end
  end

  private

  def parent_from_params
    return nil if context&.params&.parent.blank?

    gid = URI.decode_www_form_component(context.params.parent)
    GlobalID::Locator.locate(gid)
  rescue StandardError
    nil
  end
end
