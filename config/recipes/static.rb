namespace :static do

  desc "Setup load balancer"
  task :setup, roles: :static do
    template "static.erb", "/tmp/static"
    run "mv /tmp/static /etc/nginx/sites-available/static.firemind"

    run "ln -sf /etc/nginx/sites-available/static.firemind /etc/nginx/sites-enabled/static.firemind"
    run "rm -f /etc/nginx/sites-enabled/default"

    run "service nginx restart"
  end
end

