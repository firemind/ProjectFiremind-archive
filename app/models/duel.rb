class Duel < ApplicationRecord

  enum state: [ :waiting, :started, :failed, :finished]

  after_create :add_to_redis_queue

  after_initialize :default_values

  belongs_to :user
  belongs_to :assignee, class_name: "User"
  belongs_to :format
  belongs_to :card_script_submission
  has_many :games, dependent: :destroy

  belongs_to :deck_list1, class_name: 'DeckList'
  belongs_to :deck_list2, class_name: 'DeckList'

  validate :game_count_in_range
  validates_presence_of :deck_list1, :deck_list2
  validates_presence_of :format, unless: ->(r){r.freeform}
  validate :decks_are_legal_in_format, unless: ->(r){r.freeform}
  validate :decklists_not_equal, unless: ->(r){r.freeform}
  validate :decklists_are_enabled, if: ->(r){r.deck_list1 && r.deck_list2}
  belongs_to :duel_queue
  validates_presence_of :duel_queue


  scope :unfinished, lambda {
    where(state: [states[:waiting], states[:started]])
  }

  scope :visible_to, lambda { |user|
    where("public = true or user_id = ?", (user && user.id))
  }

  scope :by_matchup, lambda { |dl1, dl2|
    where(deck_list1_id: dl1, deck_list2_id: dl2)
  }

  scope :is_public, lambda {
    where(public: true)
  }

  scope :missmatching_results, lambda {
    group("deck_list1_id, deck_list2_id, starting_seed").joins(:games).having("count(distinct(winning_deck_list_id))>1")
  }

  def deck1_text
    deck_list1.as_text
  end

  def deck2_text
    deck_list2.as_text
  end

  def deck1_tag
    deck_list1.archetype || "No Archetype"
  end

  def deck2_tag
    deck_list2.archetype || "No Archetype"
  end

  def winner
    mid = (games.count.to_f / 2)
    if wins_deck1 > mid
      deck_list1
    elsif wins_deck1 < mid
      deck_list2
    else
      nil
    end
  end

  def loser
    mid = (games.count.to_f / 2).floor
    if wins_deck1 < mid
      deck_list1
    elsif wins_deck1 > mid
      deck_list2
    else
      nil
    end
  end

  def wins_deck1
    games.where(winning_deck_list_id: deck_list1_id).count
  end

  def wins_deck2
    games.where(winning_deck_list_id: deck_list2_id).count
  end

  def wins_by_ai(ai)
    raise "Not a valid ai #{ai}" unless self.ai1 == ai || self.ai2 == ai
    games.where(winning_deck_list_id: ai == self.ai1 ? deck_list1_id : deck_list2_id).count
  end

  def self.wins_by_ai(ai)
    joins(:duel_queue).
    joins("RIGHT JOIN `games` ON `games`.`duel_id` = `duels`.`id`").
      where("(winning_deck_list_id = duels.deck_list1_id and duel_queues.ai1 = ?) or (winning_deck_list_id = duels.deck_list2_id and duel_queues.ai2 = ?)", ai, ai).count
  end

  def games_played
    games.count
  end

  def scriptcheck?
    !! self.card_script_submission
  end

  def opponent_of(deck)
    raise "refactor"
    deck.id == deck1.id ? deck2 : deck1
  end

  def opponent_id_of(deck)
    raise "refactor"
    deck.id == deck1.id ? deck2_id : deck1_id
  end

  def win_loss_ratio(deck_list)
    deck_list.id == deck_list1_id ? [wins_deck1, games_played - wins_deck1] : [games_played - wins_deck1, wins_deck1 ]
  end


  def add_to_redis_queue
    duel_queue.push(self.id)
  end

  def decks_are_legal_in_format
    unless deck_list1 && deck_list1.legal_in?(format)
      self.errors.add(:deck_list1_id, "(#{self.deck_list1_id}) Not legal in #{format.to_s} (duel #{self.id})")
    end
    unless deck_list2 && deck_list2.legal_in?(format)
      self.errors.add(:deck_list2_id, "(#{self.deck_list2_id}) Not legal in #{format.to_s} (duel #{self.id})")
    end
  end

  def requeue!
    self.requeue_count += 1
    self.state = :waiting
    self.save!
    self.games.destroy_all
    self.add_to_redis_queue
  end

  def self.new_by_user(user, deck_list1, deck_list2, format)
    duel = self.new
    duel.format = format
    duel.user = user
    duel.state = 'waiting'
    duel.games_to_play = 5
    duel.public = true
    duel.deck_list1 = deck_list1
    duel.deck_list2 = deck_list2
    duel.duel_queue = DuelQueue.default
    duel
  end


  def inform_success
    unless self.user.device.blank?
      n = Rpush::Gcm::Notification.new
      n.app = Rpush::Gcm::App.find_by_name("android_app")
      n.registration_ids = [self.user.device]
      n.data = { message: "#{self.deck_list1} vs #{self.deck_list2}" }
      n.priority = 'high'        # Optional, can be either 'normal' or 'high'
      n.content_available = true # Optional
      # Optional notification payload. See the reference below for more keys you can use!
      n.notification = { #body: '',
                         title: 'Duel finished',
                         #icon: 'myicon'
                       }
      n.save!
    end
  end

  private
  def decklists_not_equal
    if deck_list1 == deck_list2
      self.errors.add(:deck_list2_id, "can not be equal to deck list 1")
    end
  end

  def decklists_are_enabled
    unless scriptcheck? || deck_list1.enabled?
      self.errors.add(:deck_list1_id, "is not enabled")
    end

    unless scriptcheck? || deck_list2.enabled?
      self.errors.add(:deck_list2_id, "is not enabled")
    end
  end

  def game_count_in_range
    max_games = 10
    if !scriptcheck? && (!games_to_play || games_to_play < 1 || games_to_play > 10)
      self.errors.add(:games_to_play, "Number of games to play has to be between 1 and #{max_games}")
    end
  end

  def default_values
    self.games_to_play ||= 5 if self.attributes.has_key?(:games_to_play) || self.new_record?
  end
end
