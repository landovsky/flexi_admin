# frozen_string_literal: true

module FlexiAdmin
  class Config
    PAGINATE_PER_OPTIONS = [12, 24, 48, 96].freeze
    PAGINATE_PER_DEFAULT = 12

    def self.paginate_per_options
      PAGINATE_PER_OPTIONS
    end

    def self.paginate_per_default
      PAGINATE_PER_DEFAULT
    end

    class Store
      attr_accessor :namespace, :module_namespace, :paginate_per, :paginate_per_options

      def initialize
        @paginate_per = PAGINATE_PER_DEFAULT
        @paginate_per_options = PAGINATE_PER_OPTIONS
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
