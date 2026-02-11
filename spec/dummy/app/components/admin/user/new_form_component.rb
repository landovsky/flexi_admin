# frozen_string_literal: true

module Admin
  module User
    class NewFormComponent < FlexiAdmin::Components::Resource::FormComponent
      attr_reader :parent

      def initialize(resource, parent: nil)
        super(resource, disabled: false)
        @parent = parent
      end

      alias user resource
    end
  end
end
