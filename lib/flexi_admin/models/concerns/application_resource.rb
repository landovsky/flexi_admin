# frozen_string_literal: true

module FlexiAdmin::Models::Concerns::ApplicationResource
  extend ActiveSupport::Concern
  include FlexiAdmin::Models::Concerns::Parentable

  class_methods do
    def fa_allowed_scopes
      []
    end
  end

  def identifier
    "#{self.class.name.underscore}_#{id}"
  end
  alias frame_id identifier

  def form_id
    "#{identifier}_form"
  end

  def gid_param
    gid = to_gid

    URI.encode_www_form_component(gid)
  end

  def raw(attribute)
    read_attribute_before_type_cast(attribute)
  end
end
