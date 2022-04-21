# Min and Max threads per worker
threads 1, 16

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
port        ENV['PORT']     || 3000
environment rails_env

if rails_env == 'development'
  # Set up socket location
  bind "unix://#{shared_dir}/sockets/puma.sock"

  ## Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

  ## Set master PID and state locations
  pidfile "#{shared_dir}/pids/puma.pid"
  state_path "#{shared_dir}/pids/puma.state"
end
#activate_control_app

#on_worker_boot do
  #require 'active_record'
  #ActiveRecord::Base.establish_connection
#end
