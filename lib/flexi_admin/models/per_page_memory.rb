# frozen_string_literal: true

module FlexiAdmin::Models
  # A user's page-size choice, remembered per list scope in a cookie. The same
  # key is written by the list's controller and read wherever the list renders
  # — its own index page, a frame request, or another resource's detail page —
  # so one choice holds everywhere that list appears, whatever its view.
  module PerPageMemory
    COOKIE_PREFIX = "fa_per_page_"

    def self.cookie_key(scope)
      "#{COOKIE_PREFIX}#{scope.to_s.parameterize(separator: '_')}"
    end

    # A cookie is user-writable, so never let it widen a query beyond the sizes
    # the app itself offers.
    def self.valid?(value)
      return false if value.blank?

      FlexiAdmin::Config.configuration.paginate_per_options.map(&:to_s).include?(value.to_s)
    end
  end
end
