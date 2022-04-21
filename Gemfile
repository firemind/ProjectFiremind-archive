ruby '2.5.1'
source 'https://rubygems.org'

# until upgrade to bundler 2.X
git_source(:github) do |repo_name| 
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.3'

gem 'meta-tags', :require => 'meta_tags'
#gem 'newrelic_rpm'

# Use sqlite3 as the database for Active Record
#gem 'sqlite3'

gem "gelf", github: "graylog-labs/gelf-rb"
gem "lograge"

gem 'puma'
gem 'mysql2'

gem 'dalli'

gem 'select2-rails'

gem 'sprockets'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

gem 'kaminari'
gem 'jquery-infinite-pages'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

gem 'acts_as_votable'

# Use jquery as the JavaScript library
gem 'jquery-rails'


gem 'whole_history_rating', require: 'whole_history_rating'

gem "sentry-raven"
gem 'activeadmin', github:'activeadmin'
gem 'inherited_resources', github: 'activeadmin/inherited_resources'

gem 'diffy'
gem 'fastimage'

gem 'algorithms'

#gem 'mlbot-api', path: 'vendor/gems/mlbot-api'
gem 'distribution'

gem "acts_as_follower", github: "tcocca/acts_as_follower"

gem 'pry-rails'
#gem 'hirb'

#gem 'protected_attributes'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks' #, '~> 5.0.0.beta'
gem 'jquery-turbolinks'

gem 'nokogiri'

gem 'redis'
gem 'redis-namespace'

gem 'sidekiq'
gem 'slim', '>= 1.1.0'

#gem 'globalize3', git: 'git://github.com/svenfuchs/globalize3.git', branch: 'rails4'

gem 'foundation-rails', '~>6.4'
gem "font-awesome-rails"
#gem 'foundation_rails_helper', path: 'vendor/gems/foundation_rails_helper'


gem 'levenshtein'

gem "devise", "~> 4.7.1"
gem 'devise_token_auth'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'omniauth-github'

gem 'rpush'

gem 'git'

gem 'rack-cors', :require => 'rack/cors'
gem 'rest-client', require: false

#gem 'netzke-core', git: 'git@github.com:netzke/netzke-core.git' #, branch: "ext42"
#gem 'netzke-basepack', git: 'git@github.com:netzke/netzke-basepack.git' #, branch: "ext42"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

gem "chartkick"
gem 'groupdate'
gem "rack-timeout"
gem 'colorize'
 
group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'guard-livereload', '~> 2.5', require: false
  gem "rack-livereload"
  #gem 'rack-mini-profiler'
  gem "bullet"
  #gem 'brakeman', :require => false
  #gem "rails_best_practices"
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'rails-erd'
  gem 'rspec_api_documentation'
  gem "letter_opener"
end

group :test do
  gem 'rspec-rails', '~> 3.6'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'rails-controller-testing'
  gem 'database_cleaner'
end
gem "apitome", github: 'jejacks0n/apitome'

#gem 'predictionio'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

#gem 'tensorflow_serving_client', path: 'vendor/gems/tensorflow_serving_client-ruby'
#gem 'tensorflow_serving_client', git: "git@github.com:firemind/tf-serving-client.git"
gem "tensorflow_serving_client", path: "gems"
