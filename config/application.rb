require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module TodoToday
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = 'Central Time (US & Canada)'
  end
end
