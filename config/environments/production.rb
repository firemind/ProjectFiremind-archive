Firemind::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.public_file_server.enabled = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'
  config.public_file_server.enabled = true
  config.action_mailer.perform_caching = false

   config.active_record.dump_schema_after_migration = false


  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]


  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)
  #config.logger = Logger.new(STDOUT)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  config.action_mailer.default_url_options = { :host => 'www.firemind.ch', :protocol => 'https' }
  require 'socket'
  #config.action_mailer.delivery_method = :sendmail
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { }

  config.action_dispatch.trusted_proxies = ""
  config.force_ssl = true
  config.x.game_log_host = "https://static.firemind.ch" 

  config.action_controller.asset_host = "https://www.firemind.ch"

	config.middleware.insert_before 0, Rack::Cors do
		allow do
			origins '*'
			resource '/api/v2/*', :headers => :any, :methods => [:get, :post, :options, :delete],
        :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
        :max_age => 0
		end
	end
  config.x.magarena_repo_path = "/mnt/fileshare/repo/magarena-csm-auto/"
  config.x.missing_cards_repo_path = "/mnt/fileshare/repo/missing-cards/"
  config.x.magarena_tracking_repo = "/mnt/fileshare/repo/magarena/"
  config.x.archetype_server = ''

  config.action_cable.allowed_request_origins = ["https://www.firemind.ch"]
  config.action_cable.url = "https://www.firemind.ch/cable/"

  config.cache_store = :dalli_store, (ENV['MEMCACHE_HOST'] || '127.0.0.1:11211'), { :namespace => "firemind" }
  config.x.tfserver = 'hub.firemind.ch:9000'
  config.x.archetype_model_path = "/mnt/fileshare/archetype-data"

  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Graylog2.new
  config.logger = GELF::Logger.new("62.12.149.54", 12201)
  config.lograge.custom_payload do |controller|
    {
      user_id: controller.current_user.try(:id),
      user: controller.current_user.try(:email),
      remote_ip: controller.request.remote_ip,
    }
  end
  config.slow_query_log_threshold_in_ms = 0.1
end

MAGARENA_MAILINGLIST = 'magarena@googlegroups.com'

$redis = Redis.new(:host => ENV['REDIS_HOST'], :port => 6379, password: '')

Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['SIDEKIQ_REDIS_URL'], :namespace => 'sidekiq'}
end

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['SIDEKIQ_REDIS_URL'], :namespace => 'sidekiq'}
end
Rails.application.routes.default_url_options = { :host => 'www.firemind.ch' }
OmniAuth.config.full_host = "https://www.firemind.ch"

LOGFILE_BASEDIR="/mnt/fileshare"
ArchetypesPersistencePrefix = "/mnt/fileshare/firemind/archetypes"

Raven.configure do |config|
  config.dsn = ''
  config.silence_ready = true
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.environments = ['production']
end

