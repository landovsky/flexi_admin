# frozen_string_literal: true

module FlexiAdmin
  class Config
    class Store
      attr_accessor :namespace, :module_namespace, :paginate_per

      def initialize
        @paginate_per = 15
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
