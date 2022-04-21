namespace :nfsserver do
  desc "Setup nfs configuration for this application"
  task :setup, roles: :nfsserver do
    run "#{sudo} mkdir -p /var/files"
    run ensure_line("/etc/exports", "/var/files *(rw,no_root_squash,sync)")
    run "#{sudo} service nfs-kernel-server restart"
  end
end
