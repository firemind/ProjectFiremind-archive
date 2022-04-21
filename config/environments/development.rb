Firemind::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true

  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.cache_store = :mem_cache_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end
  #config.action_mailer.delivery_method = :sendmail
  # Defaults to:
  # config.action_mailer.sendmail_settings = {
  #   location: '/usr/sbin/sendmail',
  #   arguments: '-i -t'
  # }

  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
    
  config.action_mailer.perform_caching = false


  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.assets.quiet = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.action_mailer.default_url_options = { :host => 'localhost' }


  config.x.game_log_host = "" 

  config.x.missing_cards_repo_path = "missing-cards-repo/" 

  config.action_controller.asset_host = "http://firemind.local"

  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'
      resource '/api/v2/*', :headers => :any, :methods => [:get, :post, :options, :delete],
        :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
        :max_age => 0
    end
  end
  config.x.magarena_tracking_repo = "magarena-repo/"
  #config.x.magarena_tracking_repo = "missing-cards-repo/"
  config.x.archetype_server = 'firemind.local'
  config.action_cable.allowed_request_origins = ["http://firemind.local", "ws://firemind.local:28080/cable"]
  config.action_cable.url = "http://firemind.local/cable/"
  config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload

  config.action_mailer.default_url_options = { :host => 'firemind.local' }

  #config.after_initialize do
    #Bullet.enable = true
    #Bullet.sentry = false
    #Bullet.bullet_logger = true
    #Bullet.console = true
    ##Bullet.growl = true
    ##Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    ##:password => 'bullets_password_for_jabber',
    ##:receiver => 'your_account@jabber.org',
    ##:show_online_status => true }
    #Bullet.rails_logger = true
    ##Bullet.honeybadger = true
    ##Bullet.bugsnag = true
    ##Bullet.airbrake = true
    ##Bullet.rollbar = true
    #Bullet.add_footer = true
    ##Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    ##Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
    ##Bullet.slack = { webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier' }
  #end
  config.x.tfserver = 'localhost:9000'
  config.x.archetype_model_path = "/archetype-data"

end
MAGARENA_MAILINGLIST = 'just-my-test-project@googlegroups.com'
$redis = Redis.new(:host => 'localhost', :port => 6379)

Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://localhost:6379', :namespace => 'sidekiq' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://localhost:6379', :namespace => 'sidekiq' }
end
LOGFILE_BASEDIR="./log/firemind/"


ArchetypesPersistencePrefix = "/var/local/firemind/archetypes"
