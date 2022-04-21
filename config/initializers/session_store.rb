require 'dalli'

require 'active_support/cache/dalli_store'

Rails.application.config.session_store ActionDispatch::Session::CacheStore, cache: ActiveSupport::Cache::DalliStore.new(
    (ENV['MEMCACHE_HOST'] || '127.0.0.1:11211'),
    namespace: 'sessions',
    key: '_firemind_session',
    raise_errors: true
  )

