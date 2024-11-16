namespace :flexi_admin do
  desc "Generate code for a given entity"
  task :codegen, [:prompt] => :environment do |_t, _args|
    prompt = ENV["prompt"]

    abort "prompt is required" if prompt.nil? || prompt.strip.empty?

    FlexiAdmin::Services::CodeGen.execute(prompt)
  end

  desc "Setup SASS path"
  task :sass_path do
    # !/usr/bin/env ruby

    # Define the array of paths
    sass_paths = []
    sass_paths << "./node_modules"

    # Get the absolute path of the gem
    gem_path = Gem::Specification.find_by_name("flexi_admin").gem_dir

    if gem_path.empty?
      warn "Error: Unable to find gem path for #{gem_name}"
      exit 1
    end

    # Add gem-related paths
    sass_paths << "#{gem_path}/app/assets/stylesheets"
    sass_paths << "#{gem_path}/app/assets/stylesheets/components"

    # Join paths with ':' and return the joined path
    puts sass_paths.join(":")
  end
end
