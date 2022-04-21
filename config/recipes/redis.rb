namespace :redis do
  desc "Setup redis configuration for this application"
  task :setup, roles: :redis do
    template "redis.erb", "/tmp/redis.conf"
    run "#{sudo} mv /tmp/redis.conf /etc/redis/redis.conf"
    run "#{sudo} service redis-server restart"
    run "#{sudo} newaliases"
  end
  task :install_crons, roles: :redis do
    template "crons.erb", "/tmp/redis.conf"
    run "#{sudo} cat /tmp/redis.conf | crontab"
    run "#{sudo} rm /tmp/redis.conf"
  end
end
