class Game < ApplicationRecord
  belongs_to :winning_deck_list, class_name: "DeckList", counter_cache: :won_games_count
  belongs_to :losing_deck_list, class_name: "DeckList", counter_cache: :lost_games_count

  belongs_to :duel, touch: true

  validates_presence_of :winning_deck_list, :losing_deck_list

  def winner
    winning_deck_list
  end

  def play_time
    Time.at(play_time_sec).utc
  end

  def play_time=(v)
    d = Time.parse(v)
    self.play_time_sec = d.hour * 3600 + d.min * 60 + d.sec
  end

  def update_meta_data!(data)
    winner_key = winning_deck_list_id == duel.deck_list1_id ? :P : :C
    loser_key  = winning_deck_list_id == duel.deck_list1_id ? :C : :P
    self.win_on_turn = data[:win_by_turn]
    self.winner_action_count = data[:players][winner_key][:action_count]
    self.winner_decision_count = data[:players][winner_key][:decision_count]
    self.loser_action_count = data[:players][loser_key][:action_count]
    self.loser_decision_count = data[:players][loser_key][:decision_count]
    self.deck_list_on_play_id = if data[:on_play] == :P 
                                  duel.deck_list1_id 
                                elsif data[:on_play] == :C
                                  duel.deck_list2_id
                                else 
                                  nil
                                end
    if data[:magarena_version]
      major, minor =  data[:magarena_version].split '.'
      duel.magarena_version_major = major
      duel.magarena_version_minor = minor
      duel.save(validate: false)
    end
    self.parsed_by = GameLogParser::VERSION
    self.save!
  end

  def log_path
    date_path = created_at.strftime("%Y/%m/%d")
    "/games/#{date_path}/#{id}.log"
  end

  def json_log_path
    date_path = created_at.strftime("%Y/%m/%d")
    "/games/#{date_path}/#{id}.json"
  end
  def json_log_url
    Rails.configuration.x.game_log_host + json_log_path
  end
end
