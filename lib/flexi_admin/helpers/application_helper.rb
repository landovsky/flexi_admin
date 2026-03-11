# frozen_string_literal: true

module FlexiAdmin::Helpers::ApplicationHelper
  def toast_class(flash_type)
    { success: 'bg-primary', error: 'bg-danger', alert: 'bg-warning', notice: 'bg-primary' }[flash_type.to_sym]
  end
end
