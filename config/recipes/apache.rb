namespace :apache do

  desc "Setup apache configuration for this application"
  task :setup, roles: :app do
    template "apache.erb", "/tmp/apache_conf"
    run "#{sudo} mv /tmp/apache_conf /etc/apache2/sites-enabled/#{application}"
    run "#{sudo} rm -f /etc/apache2/sites-enabled/000-default"
    run "#{sudo} rm -f /var/www/index.html"
    restart
  end
  after "deploy:setup", "apache:setup"

  task :init, roles: :app do
    run "#{sudo} mkdir -p #{deploy_to}/releases"
    restart
  end
  before "deploy:cold", "apache:init"


  %w[start stop restart].each do |command|
    desc "#{command} apache"
    task command, roles: :app do
      run "#{sudo} service apache2 #{command}"
    end
  end
end
