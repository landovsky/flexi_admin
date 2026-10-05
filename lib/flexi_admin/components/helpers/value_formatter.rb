# frozen_string_literal: true

module FlexiAdmin::Components::Helpers::ValueFormatter

  def as_text(value)
    value.to_s
  end

  # Times/datetimes are reduced to their date: `as: :date` on a created_at column should read
  # 2026-10-05, not the locale's full time format.
  def as_date(value, format: nil)
    return nil if value.blank?

    value = value.to_date if value.respond_to?(:to_date) && !value.is_a?(String)
    I18n.l(value, format:)
  end

  def as_navigation(value)
    helpers.link_to value, value, 'data-turbo-frame': '_top'
    # content_tag(:a, value, href: value, 'data-turbo-frame': '_top')
  end

  def format(formatter)
    case formatter.to_sym
    when :date
      proc { |value| as_date(value) }
    when :text
      proc { |value| as_text(value) }
    when :navigation
      proc { |value| as_navigation(value) }
    else
      raise ArgumentError, "Unknown formatter: #{@formatter}"
    end
  end
end
