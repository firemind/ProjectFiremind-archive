class PushCardscriptWorker
  include Sidekiq::Worker
  include Gitlock

  def perform(card_script_submission_id)
    subm = CardScriptSubmission.find card_script_submission_id
    git_path = Rails.configuration.x.magarena_repo_path
    escaped_card_name = (subm.card && subm.card.name || subm.token_name).gsub(/[^A-Za-z0-9]/, "_")

    gitlock git_path do
      g= Git.open git_path

      config_path = "#{script_path("#{escaped_card_name}.txt")}"
      File.open("#{git_path}/#{config_path}", 'w') { |file| file.write(subm.config) }
      g.add config_path

      if subm.script && !subm.script.empty?
        sp_path = "#{script_path("#{escaped_card_name}.groovy")}"
        File.open("#{git_path}/#{sp_path}", 'w') { |file| file.write(subm.script) }
        g.add sp_path
      end
      if subm.user
        g.config('user.name', subm.user.to_s )
        g.config('user.email', subm.user.email)
      else
        g.config('user.name', 'Guest')
        g.config('user.email', 'system@firemind.ch')
      end
      g.commit "Add script for #{(subm.card || subm.token_name ).to_s.gsub('"','\"')}"
      g.push if Rails.env.production?
      subm.pushed = true
      subm.save(validate: false)
    end
    
  end

  def script_path(script)
    "release/Magarena/scripts/#{script}"
  end



end
