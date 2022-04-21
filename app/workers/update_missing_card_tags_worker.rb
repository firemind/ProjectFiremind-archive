class UpdateMissingCardTagsWorker
  include Sidekiq::Worker
  include Gitlock

  def perform(card_id)
    card = Card.find card_id
    git_path = Rails.configuration.x.missing_cards_repo_path
    escaped_card_name = card.name.gsub(/[^A-Za-z0-9]/, "_")

    rel_missing_dir = "release/Magarena/scripts_missing/"
    missing_scripts_path = File.join git_path, '/', rel_missing_dir

    gitlock git_path do
      g= Git.open git_path


      rel_missing_config_file = "#{rel_missing_dir}/#{escaped_card_name}.txt"
      config_path = "#{missing_scripts_path}/#{escaped_card_name}.txt"
      unless File.exists? config_path
        raise "Card Config ist not in missing path #{config_path}"
      end

      if user = card.config_updater
        g.config('user.name', user.to_s )
        g.config('user.email', user.email)
      else
        raise "config_updater was not set on card #{card}"
      end

      orig_content = File.read(config_path).split("\n")

      orig_content.delete_if {|l| l =~ /^status=not supported:/ }
      if card.not_implementable_reasons.size > 0
        orig_content << "status=not supported: #{card.not_implementable_reasons.map(&:name).join(', ')}"
      end

      File.open(config_path, 'w') { |file| file.write(orig_content.join("\n")+"\n") }
      g.add rel_missing_config_file

      g.commit "Update missing card status for #{card}"
      g.push(g.remote('origin'), 'not-implementable') if Rails.env.production?
    end
    
  end





end
