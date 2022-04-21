namespace :sim do

  task :feed_duels => :environment do
    dq = DuelQueue.default
    while true
      duel = dq.duels.sample
      duel.state = ["waiting", "started", "failed", "finished"].sample
      DuelInformWorker.new.broadcast_duel(duel)
      sleep 0.5
    end

  end

  task :worker => :environment do 
    raise "Only dev" unless Rails.env.development?
    #q = DeckChallenge.find(2).duel_queue
    q = DuelQueue.default
    while true
      if duel_id = q.pop
        duel = Duel.where(id: duel_id).first
        next unless duel&.waiting?
        duel.state = "started"
        #duel.assignee_id = @user.id
        duel.save!
        DuelInformWorker.perform_async duel.id
        parts = [duel.deck_list1_id, duel.deck_list2_id]
        duel.games_to_play.times do |i|
          sleep 2
          winner,loser = parts.shuffle
          g = duel.games.build({
            game_number: i,
            play_time_sec: rand(100)+30,
            winning_deck_list_id: winner,
            losing_deck_list_id: loser,
          })
          g.save!
          DuelInformWorker.perform_async duel.id
        end
        duel.state = "finished"
        duel.save!
        DuelInformWorker.perform_async duel.id
      else
        puts "No duels ..."
      end
      sleep 2
    end
  end

end
