AIWORKER_SCRIPT = "/usr/local/magarena/aiworker"
namespace :aiworker do
  desc "Setup aiworker"
  task :setup, roles: :aiworker do
    template "aiworker.erb", "/tmp/aiworker"
    run "#{sudo} mv /tmp/aiworker /etc/init.d/"
    run "#{sudo} chmod +x /etc/init.d/aiworker"

    template "aiworker_script.erb", "/tmp/aiworker"
    run "#{sudo} mv /tmp/aiworker /usr/local/magarena/"
    run "#{sudo} chmod +x /usr/local/magarena/aiworker"
    run "#{sudo} echo 'firemindAccesToken=bd0757866bfe88cee8c5f632caf2238b' >> /usr/local/magarena/release/Magarena/general.cfg"
  end

  desc "Update aiworker"
  task :update, roles: :aiworker do
    #run "cd /usr/local/magarena/ && git pull"
    run "rsync -av root@#{AIWORKER_SOURCE_SERVER}:/var/files/Magarena_release/ /mnt/fileshare/magarena/release/ --delete"
  end

  desc "Starting aiworker"
  task :start, roles: :aiworker do
    run "/etc/init.d/aiworker start"
  end

  desc "Stop aiworker"
  task :stop, roles: :aiworker do
    #run "/etc/init.d/aiworker stop"
    run "pkill -f magic[\.]DeckStrCalAPI || true"
  end

  desc "Restarting aiworker"
  task :restart, roles: :aiworker do
    stop
    start
  end

end
