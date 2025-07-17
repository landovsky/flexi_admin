# frozen_string_literal: true

module FlexiAdmin
  module Components
    module Actions; end
    module Form; end
    module Helpers; end
    module Resource; end

    module Resources
      module ListView; end
      module GridView; end
      module BulkAction; end
    end

    module Shared
      module Table; end
    end
  end
end

# Base Component
require_relative "components/base_component"

# Nav Components
require_relative "components/nav/floating_toc_component"

# Helpers
require_relative "components/helpers/action_button_helper"
require_relative "components/helpers/action_helper"
require_relative "components/helpers/icon_helper"
require_relative "components/helpers/link_helper"
require_relative "components/helpers/url_helper"
require_relative "components/helpers/resource_helper"
require_relative "components/helpers/selectable"
require_relative "components/helpers/value_formatter"
require_relative "components/helpers/frontend_helper"

require_relative "components/resource/form_mixin"

# Action Components
require_relative "components/actions/checkbox_component"
require_relative "components/actions/select_component"

# Form Components
require_relative "components/form/field_component"
require_relative "components/form/label_component"
require_relative "components/form/rows_component"
require_relative "components/form/text_input_component"

# Resource Components
require_relative "components/resource/autocomplete_component"
require_relative "components/resource/filter_component"
require_relative "components/resource/button_select_component"
require_relative "components/resource/form_component"
require_relative "components/resource/form_element_component"
require_relative "components/resource/link_action_component"
require_relative "components/resource/show_page_component"
require_relative "components/resource/view_component"

# Resources Component
require_relative "components/resources/index_page_component"
require_relative "components/resources/list_view_component"
require_relative "components/resources/pagination_component"
require_relative "components/resources/resources_component"
require_relative "components/resources/switch_view_component"
require_relative "components/resources/view_component"

# Shared Components
require_relative "components/shared/autocomplete/results_component"
require_relative "components/shared/datalist_component"
require_relative "components/shared/medium_component"
require_relative "components/shared/table/header_item_component"
require_relative "components/shared/trix_component"
require_relative "components/shared/link_component"

# Resources List View Components
require_relative "components/resources/list_view/cell_component"
require_relative "components/resources/list_view/table_component"

# Resources Grid View Components
require_relative "components/resources/grid_view/card_component"
require_relative "components/resources/grid_view/grid_component"
require_relative "components/resources/grid_view_component"
require_relative "components/resources/list_view_component"

# Bulk Action Components
require_relative "components/resources/bulk_action/modal_component"
require_relative "components/resources/bulk_action/button_component"
