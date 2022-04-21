namespace :lb do

  desc "Setup load balancer"
  task :setup, roles: :web do
    template "nginx.erb", "/tmp/nginx.cnf"
    run "mv /tmp/nginx.cnf /etc/nginx/nginx.conf"

    template "lb.erb", "/tmp/lb.cnf"
    run "mv /tmp/lb.cnf /etc/nginx/sites-available/firemind"

    run "ln -sf /etc/nginx/sites-available/firemind /etc/nginx/sites-enabled/firemind"
    run "rm -f /etc/nginx/sites-enabled/default"

    run "service nginx restart"
  end
end

