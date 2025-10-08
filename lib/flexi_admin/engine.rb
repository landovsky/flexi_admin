# frozen_string_literal: true

module FlexiAdmin
  class Engine < ::Rails::Engine
    isolate_namespace FlexiAdmin

    initializer "flexi_admin.locale" do
      config.i18n.load_path += Dir[root.join('config', 'locales', '*.yml')]
    end

    initializer "flexi_admin.assets" do |app|
      app.config.assets.precompile += %w[flexi_admin_main.scss flexi_admin.js]
      app.config.assets.paths << root.join("app/flexi_admin/javascript")
    end

    initializer "flexi_admin.helpers" do
      ActiveSupport.on_load(:action_controller) do
        include FlexiAdmin::Helpers::ApplicationHelper
      end

      ActiveSupport.on_load(:view_component) do
        include Rails.application.routes.url_helpers
      end
    end

    # initializer "flexi_admin.stimulus_controllers" do |app|
    #   app.config.stimulus_modules |= [
    #     { name: "flexi-admin", path: "flexi_admin/controllers" }
    #   ]
    # end

    config.to_prepare do
      Dir.glob(Engine.root.join("app", "**", "*_decorator*.rb")).each do |c|
        require_dependency(c)
      end
    end
  end
end
