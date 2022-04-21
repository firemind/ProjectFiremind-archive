namespace :ratings do

  desc "Calculate Whole History Rating"
  task :calc_whr => :environment do
    Format.enabled.each do |format|
      duel_ids = format.duels.finished.select(:id)
      games = Game.where("duel_id in (#{duel_ids.to_sql})").select(:id, :losing_deck_list_id, :winning_deck_list_id, :created_at)

      whr_calc = WhrCalculator.new
      whr_calc.load games
      whr_calc.run

      ratings = format.ratings.map{|r| [r.deck_list_id, r]}.to_h
      whr_calc.decks.each do |key, p|
        id = key.to_i
        rating = ratings[id] || Rating.new(format_id: format.id, deck_list_id: id)
        whr_data = whr_calc.raw_ratings_for(key).last
        rating.whr_rating = whr_data[1]
        rating.whr_uncertainty = whr_data[2]
        rating.save!
      end
      rating_update_time = Time.now-whr_calc.start_time-whr_calc.whr_iteration_time

      format.legal_cards.enabled.in_decks.each do |c| 
        c.calc_magarena_rating! 
      end

      card_rating_update_time = Time.now-whr_calc.start_time-rating_update_time

      if Rails.env.production?
        Rails.logger.notify! short_message: "whr_calculation", :_whr_iter_time => whr_calc.whr_iteration_time, :_game_loading_time => whr_calc.game_loading_time, :_rating_update_time => rating_update_time, :_format => format.name, :_card_rating_update_time => card_rating_update_time
      end
    end
  end
  desc "Calculate ELO"
  task :calc_elo => :environment do
    Format.enabled.each do |format|
      duel_ids = format.duels.finished.select(:id)
      games = Game.where("duel_id in (#{duel_ids.to_sql})").select(:id, :losing_deck_list_id, :winning_deck_list_id, :created_at)


      ratings = format.ratings.map{|r| [r.deck_list_id, r]}.to_h
      games.each do |game|
        match = EloRating::Match.new
        rating1 = (ratings[game.winning_deck_list_id] ||= Rating.new(format_id: format.id, deck_list_id: game.winning_deck_list_id))
        rating2 = (ratings[game.losing_deck_list_id] ||= Rating.new(format_id: format.id, deck_list_id: game.losing_deck_list_id))
        match.add_player(rating: rating1.elo_rating||2000, winner: true)
        match.add_player(rating: rating2.elo_rating||2000)
        v1, v2 = match.updated_ratings
        rating1.elo_rating = v1
        rating2.elo_rating = v2
      end
      ratings.each{|k,v| v.save!}
    end
  end
  desc "Calculate WP"
  task :calc_wp => :environment do
    Format.enabled.each do |format|
      duel_ids = format.duels.finished.select(:id)
      scope = Game.where("duel_id in (#{duel_ids.to_sql})")
      wins = scope.select("count(games.id) wins, winning_deck_list_id").group(:winning_deck_list_id).map{|g| [g.winning_deck_list_id, g.wins]}.to_h
      losses = scope.select("count(games.id) losses, losing_deck_list_id").group(:losing_deck_list_id).map{|g| [g.losing_deck_list_id, g.losses]}.to_h

      ratings = format.ratings.map{|r| [r.deck_list_id, r]}.to_h

      (wins.keys|losses.keys).each do |k|
        rating = (ratings[k] ||= Rating.new(format_id: format.id, deck_list_id: k))
        w = wins[k]
        l = losses[k]
        rating.value = if w.nil?
          0
        elsif l.nil?
          1
        else
          w.to_f/(w+l)
        end
      end
      ratings.each{|k,v| v.save!}
    end
  end
  task :calc_exp => :environment do
    Format.enabled.each do |format|
      duel_ids = format.duels.finished.select(:id)
      games = Game.where("duel_id in (#{duel_ids.to_sql})").select(:losing_deck_list_id, :winning_deck_list_id)

      wins   = games.group_by(&:winning_deck_list_id).map{|g,r| [g, r.group_by(&:losing_deck_list_id).map{|g2,r2| [g2,r2.size]}.to_h]}.to_h
      losses = games.group_by(&:losing_deck_list_id).map{|g,r| [g, r.group_by(&:winning_deck_list_id).map{|g2,r2| [g2,r2.size]}.to_h]}.to_h

      ratings = format.ratings.map{|r| [r.deck_list_id, r]}.to_h
      all_ids = (wins.keys|losses.keys)
      all_ids.each do |k|
        rating = (ratings[k] ||= Rating.new(format_id: format.id, deck_list_id: k))

        rating.exp_rating = all_ids.inject(0.0) do |t,o|
          w = wins.dig k, o
          l = losses.dig k, o
          m = (r=ratings[o])&&r.value || 0.5
          ratio = if w.nil?
            l ? 0 : 0.5
          elsif l.nil?
            1
          else
            w.to_f/(w+l)
          end
          t + (ratio*m)**0.5
        end / all_ids.size
      end
      ratings.each{|k,v| v.save!}
    end
  end
  task :list => :environment do
    scope = Format.modern.ratings.where.not(elo_rating: nil)
    elo_list = scope.order(elo_rating: :desc).each_with_index.to_h
    whr_list = scope.order(whr_rating: :desc).each_with_index.to_h
    exp_list = scope.order(exp_rating: :desc).each_with_index.to_h
    wp_list = scope.order(value: :desc).each_with_index.to_h
    scope.order(elo_rating: :desc).each_with_index do |rating|
      i = wp_list[rating]
      j = elo_list[rating]
      k = whr_list[rating]
      l = exp_list[rating]
      puts "#{rating.deck_list_id} | #{rating.value.round(3)} (#{i}) \t| #{rating.elo_rating} (#{j}) \t| #{rating.whr_rating} (#{k}) \t| #{rating.exp_rating.round(3)} (#{l})"
    end
  end
  task :sim => :environment do
    formats = Format.enabled.pluck(:id)
    scope = Game.joins(:duel).where(duels: {format_id: formats}).order("rand()")
    scorings = %w(value elo_rating whr_rating exp_rating).map{|k| [k, [0,0]] }.to_h
    puts scorings.keys.map{|s| s.ljust 10}.join(" | ")
    while true
      scope.includes(:winning_deck_list, :losing_deck_list).first(100).each do |g|
        wr = g.winning_deck_list.rating_in(g.duel.format)
        lr = g.losing_deck_list.rating_in(g.duel.format)
        next unless wr and lr
        scorings.each do |k, v|
          ws = wr.send k
          ls = lr.send k
          if ws != ls
            v[ws > ls ? 0 : 1] += 1
          end
        end
      end
      print "\r"
      scorings.each do |k, v|
        ratio = v[1] > 0 ? v[0].to_f/(v[0]+v[1]) : 1.0
        print "#{"%.8f" % ratio} | "
      end
    end
  end
end
