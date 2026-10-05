# frozen_string_literal: true

# Standalone index for the nested comments route (/admin/users/:user_id/comments).
# render_index in the controller looks this component up by naming convention.
module Admin
  module Comment
    class IndexPageComponent < FlexiAdmin::Components::Resources::IndexPageComponent
    end
  end
end
