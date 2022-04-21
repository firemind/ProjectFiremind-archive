namespace :queue do
  task :create_new_default => :environment do
    DuelQueue.transaction do
      dq = DuelQueue.default
      dq.name = "default-#{dq.magarena_version_major}.#{dq.magarena_version_minor}"
      dq.active= false
      dq.save
      dqnew = dq.dup
      dqnew.name = "default"
      dqnew.active= true
      dqnew.magarena_version_major, dqnew.magarena_version_minor = CURRENT_MAGARENA_VERSION.split(".")
      dqnew.save
    end
  end
end
