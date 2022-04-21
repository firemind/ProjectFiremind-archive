web:    bundle exec puma -C config/puma.rb 
worker: bundle exec sidekiq
cable:  bundle exec puma -p 28080 -C cable/puma.rb cable/config.ru
guard: bundle exec guard
