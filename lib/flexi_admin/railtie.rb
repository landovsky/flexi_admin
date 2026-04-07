require "rails"

# Don't need this for now
# require "flexi_admin/engine"

module FlexiAdmin
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/flexi_admin.rake"
    end

    initializer "flexi_admin.locale" do |app|
      app.config.i18n.load_path += Dir[absolute_gem_path("config/locales/*.yml")]
    end

    initializer "flexi_admin.asset_paths" do |_app|
      # This enables
      setup_node_path
      setup_sass_path
    end

    initializer "flexi_admin.configure" do |app|
      # Add any additional configuration here
    end

    initializer "flexi_admin.assets" do |app|
      # Add asset paths to host application
      app.config.assets.paths << absolute_gem_path("lib/flexi_admin/javascript")
      app.config.assets.paths << absolute_gem_path("app/assets/stylesheets")
    end

    # # Configure importmap if using it
    # initializer "flexi_admin.importmap", before: "importmap" do |app|
    #   if app.config.respond_to?(:importmap)
    #     app.config.importmap.paths << absolute_gem_path("app/flexi_admin/javascript")
    #   end
    # end

    # initializer "flexi_admin.helpers" do
    #   ActiveSupport.on_load(:action_controller) do
    #     include FlexiAdmin::Helpers::ApplicationHelper
    #   end
    # end

    initializer "flexi_admin.add_view_paths" do |_app|
      # Assuming your gem has a `app/views` directory
      custom_views_path = File.expand_path("../flexi_admin/views", __dir__)

      # Add the path to the application's view paths
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.prepend_view_path(custom_views_path)
      end
    end

    def absolute_gem_path(path)
      [Gem::Specification.find_by_name("flexi_admin").gem_dir, path].join("/")
    end

    def setup_node_path
      node_paths ||= []
      node_paths << "./node_modules"
      node_paths << absolute_gem_path("lib/flexi_admin/javascript")
      ENV["NODE_PATH"] = node_paths.join(":")

      # Set the NODE_PATH for the current bash session
      # https://nodejs.org/api/modules.html#loading-from-the-global-folders
      system("export NODE_PATH=#{ENV["NODE_PATH"]}")
    end

    def setup_sass_path
      sass_paths ||= []
      sass_paths << "./node_modules"
      sass_paths << absolute_gem_path("app/assets/stylesheets")
      sass_paths << absolute_gem_path("app/assets/stylesheets/components")
      ENV["SASS_PATH"] = sass_paths.join(":")

      # Set the SASS_PATH for the current bash session
      # https://sass-lang.com/documentation/cli/ruby-sass/#load-path
      system("export SASS_PATH=#{ENV["SASS_PATH"]}")
    end
  end
end
