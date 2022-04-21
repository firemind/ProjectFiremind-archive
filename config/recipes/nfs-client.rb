namespace :nfscl do
  desc "Setup nfs-client configuration for this application"
  task :setup, roles: :nfscl do
    run "#{sudo} mkdir -p /mnt/fileshare"
    run ensure_line("/etc/fstab", "#{NFS_SERVER}:/var/files        /mnt/fileshare  nfs     rw      0       0")
    run "mount -a"
  end
end
