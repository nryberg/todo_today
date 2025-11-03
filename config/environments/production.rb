require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present? || Rails.env.production?
  config.assets.compile = true
  config.active_storage.service = :local
  config.log_level = :info
  config.log_tags = [ :request_id ]

  # Force SSL in production (disable for home server)
  config.force_ssl = false

  # Host configuration for home server
  config.hosts << "bigbox"
  config.hosts << ENV["APP_HOST"] if ENV["APP_HOST"].present?

  # Allow all hosts for home server deployment
  config.hosts.clear
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = {
    host: ENV["APP_HOST"] || "bigbox",
    port: ENV["APP_PORT"] || 3000
  }
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
