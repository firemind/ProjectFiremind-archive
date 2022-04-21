Firemind::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr
  config.action_mailer.default_url_options = { :host => '192.168.50.10' }
  config.active_support.test_order = :sorted

  config.x.magarena_repo_path = "tmp/test_repo/"
  config.x.missing_cards_repo_path = "tmp/test_missing_repo/"
  config.x.magarena_tracking_repo = "test/test_magarena_repo/"

end

MAGARENA_MAILINGLIST = 'just-my-test-project@googlegroups.com'
$redis = Redis.new(:host => '127.0.0.1', :port => 6379)

Sidekiq.configure_server do |config|
    config.redis = { :url => 'redis://127.0.0.1:6379', :namespace => 'sidekiq_test' }
end

Sidekiq.configure_client do |config|
    config.redis = { :url => 'redis://127.0.0.1:6379', :namespace => 'sidekiq_test' }
end
LOGFILE_BASEDIR="tmp"
ArchetypesPersistencePrefix = "./test/archetype_nn/archetypes"
