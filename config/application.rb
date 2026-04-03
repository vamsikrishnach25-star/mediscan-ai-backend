require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MediscanBackend
  class Application < Rails::Application
    config.load_defaults 7.1

    config.middleware.insert_before 0, Rack::Cors   # 👈 ADD THIS

    config.autoload_lib(ignore: %w(assets tasks))
    config.autoload_paths << Rails.root.join("app/lib")
    config.autoload_paths << Rails.root.join("lib")

    config.api_only = true
  end
end
