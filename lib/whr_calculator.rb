class WhrCalculator
  attr_accessor :whr, :start_time, :game_loading_time, :whr_iteration_time
  def load(games)
    self.start_time = Time.now
    self.whr = WholeHistoryRating::Base.new
    games.includes(:winning_deck_list, :losing_deck_list).find_each(batch_size: 1000) do |game|
      if game.winning_deck_list && game.losing_deck_list
        whr.create_game("#{game.winning_deck_list_id}", "#{game.losing_deck_list_id}", 'B', game.created_at.strftime("%Y%m%d").to_i, 0)
      end
    end
    self.game_loading_time = Time.now-@start_time
  end

  def run
    whr.iterate(50)
    self.whr_iteration_time = Time.now-start_time-game_loading_time
  end

  def ratings_for(deck)
    raw_ratings_for(deck).map{|v|
      y,m,d = v[0].to_s[0..3].to_i,v[0].to_s[4..5].to_i,v[0].to_s[6..7].to_i
      [Date.new(y,m,d), v[1]]
    }
  end

  def raw_ratings_for(deck)
    whr.ratings_for_player(deck)
  end

  def decks
    whr.players
  end
end
