# frozen_string_literal: true

module FlexiAdmin::Components::Resources::GridView
  class CardComponent < FlexiAdmin::Components::BaseComponent
    include FlexiAdmin::Components::Helpers::LinkHelper

    attr_accessor :resource, :title, :header, :description, :image
    attr_reader :context

    def initialize(resource, title, header, description, image, context = nil)
      @resource = resource
      @title = title
      @header = header
      @description = description
      @image = image
      @context = context
    end

    def media_attachment
      @media_attachment ||= image.value[resource]
    end

    def image_src
      return unless image
      return if media_attachment.blank?

      image.src(media_attachment, variant: :thumb)
    end

    def media?
      return false unless image
      return false if media_attachment.blank?

      true
    end

    def render_media
      case media_attachment.content_type.split("/").first
      when "image"
        content_tag :img, nil, src: image_src, style: "object-fit: cover; width: 100%; height: 180px;"
      when "video"
        content_tag :video, nil, src: image_src, style: "object-fit: cover; width: 100%; height: 180px;",
                                 controls: true,
                                 onmouseover: "this.play()",
                                 onmouseout: "this.pause()"
      end
    end

    def title_value
      return unless title

      title.formatted_value(title.value[resource])
    end

    def header_value
      return unless header

      header.formatted_value(header.value[resource])
    end

    def description_value
      return unless description

      description.formatted_value(description.value[resource])
    end
  end
end
