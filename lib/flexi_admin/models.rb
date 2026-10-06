# frozen_string_literal: true

module FlexiAdmin
  module Models
    module Concerns; end
    module Resources; end
  end
end

# Core
require_relative "models/context_params"
require_relative "models/per_page_memory"
require_relative "models/struct"
require_relative "models/toast"

# Concerns
require_relative "models/concerns/parentable"
require_relative "models/concerns/application_resource"

# Resources
require_relative "models/resources/context"
