# frozen_string_literal: true

# Custom RSpec matchers for FlexiAdmin components

# Bulk action matchers
RSpec::Matchers.define :have_bulk_action_button do |action_name|
  match do |page|
    page.has_button?(action_name) || page.has_link?(action_name)
  end

  failure_message do |page|
    "expected page to have bulk action button '#{action_name}'"
  end
end

RSpec::Matchers.define :have_bulk_actions do
  match do |page|
    page.has_css?('.bulk-actions, [data-controller*="bulk-action"]')
  end

  failure_message do
    "expected page to have bulk actions component"
  end
end

# Table and column matchers
RSpec::Matchers.define :have_sortable_column do |column_name|
  match do |page|
    page.has_css?(
      "th[data-sort-column='#{column_name}'], " \
      "th a[href*='sort=#{column_name}'], " \
      "th[data-action*='click->sort']",
      text: /#{Regexp.escape(column_name.to_s.humanize)}/i
    )
  end

  failure_message do |page|
    "expected page to have sortable column '#{column_name}'"
  end
end

RSpec::Matchers.define :have_filterable_column do |column_name|
  match do |page|
    page.has_css?(
      "select[name*='#{column_name}'], " \
      "input[name*='#{column_name}'], " \
      "[data-filter-column='#{column_name}']"
    )
  end

  failure_message do
    "expected page to have filterable column '#{column_name}'"
  end
end

# Pagination matchers
RSpec::Matchers.define :have_pagination_controls do
  match do |page|
    has_pagination = page.has_css?('.pagination, [data-controller*="pagination"]')
    has_navigation = page.has_link?('←') || page.has_link?('Previous')

    has_pagination || has_navigation
  end

  failure_message do
    "expected page to have pagination controls"
  end
end

RSpec::Matchers.define :have_per_page_selector do
  match do |page|
    page.has_select?('per_page') ||
      page.has_css?('select[name="per_page"], select[data-action*="pagination"]')
  end

  failure_message do
    "expected page to have per-page selector"
  end
end

# Form matchers
RSpec::Matchers.define :have_form_field do |field_name, options = {}|
  match do |page|
    if options[:type]
      page.has_field?(field_name, type: options[:type])
    else
      page.has_field?(field_name)
    end
  end

  failure_message do
    type_msg = options[:type] ? " of type '#{options[:type]}'" : ""
    "expected page to have form field '#{field_name}'#{type_msg}"
  end
end

RSpec::Matchers.define :have_editable_form do
  match do |page|
    page.has_css?(
      'form[data-controller*="edit"], ' \
      'form input:not([disabled]), ' \
      'form select:not([disabled]), ' \
      'form textarea:not([disabled])'
    )
  end

  failure_message do
    "expected page to have an editable form"
  end
end

# Stimulus controller matchers
RSpec::Matchers.define :have_stimulus_controller do |controller_name|
  match do |page|
    page.has_css?("[data-controller='#{controller_name}'], [data-controller*='#{controller_name}']")
  end

  failure_message do
    "expected page to have Stimulus controller '#{controller_name}'"
  end
end

# Flash message matchers
RSpec::Matchers.define :have_success_message do |message = nil|
  match do |page|
    if message
      page.has_css?('.alert-success, .toast-success, [data-flash-type="success"]', text: message)
    else
      page.has_css?('.alert-success, .toast-success, [data-flash-type="success"]')
    end
  end

  failure_message do
    message_part = message ? " with text '#{message}'" : ""
    "expected page to have success message#{message_part}"
  end
end

RSpec::Matchers.define :have_error_message do |message = nil|
  match do |page|
    if message
      page.has_css?('.alert-error, .alert-danger, .toast-error, [data-flash-type="error"]', text: message)
    else
      page.has_css?('.alert-error, .alert-danger, .toast-error, [data-flash-type="error"]')
    end
  end

  failure_message do
    message_part = message ? " with text '#{message}'" : ""
    "expected page to have error message#{message_part}"
  end
end

# Component presence matchers
RSpec::Matchers.define :have_resource_table do
  match do |page|
    page.has_css?('table.resources-table, table[data-controller*="resource"]')
  end

  failure_message do
    "expected page to have a resource table"
  end
end

RSpec::Matchers.define :have_search_field do
  match do |page|
    page.has_field?('q') ||
      page.has_field?('search') ||
      page.has_css?('input[type="search"], [data-controller*="search"]')
  end

  failure_message do
    "expected page to have a search field"
  end
end
