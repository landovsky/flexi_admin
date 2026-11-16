# frozen_string_literal: true

module FlexiAdmin
  class Config
    PAGINATE_PER_OPTIONS = [12, 24, 48, 96].freeze
    PAGINATE_PER_DEFAULT = 12
    # How many rows an autocomplete offers when the field is focused but empty.
    AUTOCOMPLETE_SUGGESTIONS_DEFAULT = 12
    # Submit buttons lock, spin while saving and then show ✓ / ✕ (submit_button_controller.js).
    # Set to false to get the plain pre-0.0.8 <input type="submit"> everywhere.
    SUBMIT_BUTTON_STATES_DEFAULT = true

    def self.paginate_per_options
      PAGINATE_PER_OPTIONS
    end

    def self.paginate_per_default
      PAGINATE_PER_DEFAULT
    end

    class Store
      attr_accessor :namespace, :module_namespace, :paginate_per, :paginate_per_options,
                    :autocomplete_suggestions, :submit_button_states

      def initialize
        @paginate_per = PAGINATE_PER_DEFAULT
        @paginate_per_options = PAGINATE_PER_OPTIONS
        @autocomplete_suggestions = AUTOCOMPLETE_SUGGESTIONS_DEFAULT
        @submit_button_states = SUBMIT_BUTTON_STATES_DEFAULT
      end
    end

    class << self
      attr_writer :configuration

      def configuration
        @configuration ||= FlexiAdmin::Config::Store.new
      end

      def configure
        yield(configuration)
        WillPaginate.per_page = configuration.paginate_per
      end
    end
  end
end
