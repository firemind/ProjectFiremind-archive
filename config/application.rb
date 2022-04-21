require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'action_dispatch/middleware/session/dalli_store'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Firemind
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.load_defaults 5.1
    config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths += %W(#{config.root}/lib/worker_helpers #{config.root}/app/searchers)
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Bern'
    config.active_record.belongs_to_required_by_default = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.active_record.time_zone_aware_types = [:datetime, :time]
    config.filter_parameters << :password
  end
end


IMAGE_SERVER_URL = "https://static.firemind.ch/scans/"
BANNER_SERVER_URL = "https://static.firemind.ch/banners/"
THUMB_SERVER_URL = "https://static.firemind.ch/thumbs/"
CURRENT_MAGARENA_VERSION = "1.95"
PRICE_PRECISION = 5
ArchetypeNnPort = 4000
COLORS = ['W','U','B','R','G']
BASIC_LANDS_BY_COLOR = {
 W: 'Plains',
 U: 'Island',
 B: 'Swamp',
 R: 'Mountain',
 G: 'Forest'
}
MIN_ARCHETYPE_SCORE = 0.3
