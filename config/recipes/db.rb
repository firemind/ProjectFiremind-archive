namespace :db do
  task :setup, roles: [:dbmaster1, :dbmaster2] do
    setup_m1
    setup_m2
  end

  desc "Setup database"
  task :setup_m1, roles: :dbmaster1 do
    #template "mycnf1.erb", "/tmp/my.cnf"
    #run "#{sudo} mv /tmp/my.cnf /etc/mysql/my.cnf"
    #run "#{sudo} service mysql restart"
    #run %(echo "grant replication slave on *.* to 'replication'@#{MYSQL_MASTER2[:ip]} identified by 'slave';" | mysql -u root -p) do |channel, stream, data|
      #if data =~ /^Enter password:/
        #channel.send_data "#{MYSQL_MASTER1[:pw]}\n"
      #end
      #puts data # data gets updated after mysql command executes!
    #end
    #run %(echo "stop slave; CHANGE MASTER TO MASTER_HOST='#{MYSQL_MASTER2[:ip]}', MASTER_USER='replication', MASTER_PASSWORD='slave'; start slave;"| mysql -u root -p) do |channel, stream, data|
      #if data =~ /^Enter password:/
        #channel.send_data "#{MYSQL_MASTER2[:pw]}\n"
      #end
      #puts data # data gets updated after mysql command executes!
    #end
    set :replhost, MYSQL_MASTER1
    setup_replmon
  end

  task :setup_m2, roles: :dbmaster2 do
    #template "mycnf2.erb", "/tmp/my.cnf"
    #run "#{sudo} mv /tmp/my.cnf /etc/mysql/my.cnf"
    #run "#{sudo} service mysql restart"
    #run %(echo "grant replication slave on *.* to 'replication'@#{MYSQL_MASTER1[:ip]} identified by 'slave';" | mysql -u root -p) do |channel, stream, data|
      #if data =~ /^Enter password:/
        #channel.send_data "#{MYSQL_MASTER2[:pw]}\n"
      #end
      #puts data # data gets updated after mysql command executes!
    #end
    #run %(echo "stop slave; CHANGE MASTER TO MASTER_HOST='#{MYSQL_MASTER1[:ip]}', MASTER_USER='replication', MASTER_PASSWORD='slave';start slave; " | mysql -u root -p) do |channel, stream, data|
      #if data =~ /^Enter password:/
        #channel.send_data "#{MYSQL_MASTER2[:pw]}\n"
      #end
      #puts data # data gets updated after mysql command executes!
    #end
    set :replhost, MYSQL_MASTER2
    setup_replmon
  end

  task :setup_replmon, roles: :db do
    template "replicationcheck.erb", "/tmp/replicationcheck"
    run "#{sudo} mv /tmp/replicationcheck /usr/local/bin/replicationcheck"
    run "#{sudo} chmod +x /usr/local/bin/replicationcheck"
    run "#{sudo} mkdir -p /var/run/monit/"
    run "#{sudo} echo '* * * * * /usr/local/bin/replicationcheck' | crontab"
  end

end
