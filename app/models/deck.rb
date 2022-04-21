class Deck < ApplicationRecord

  include Decklistable
  has_many :maybe_entries, dependent: :destroy
  has_many :ratings, through: :deck_list
  has_many :sideboard_plans
  belongs_to :format
  belongs_to :author, class_name: 'User'
  belongs_to :forked_from, class_name: 'DeckList'
  has_many :forks, foreign_key: 'forked_from_id', class_name: 'Deck'
  after_save :cleanup_clusters, if: ->(r){r.decklist_changed}
  has_many :deck_entry_clusters, dependent: :destroy
  has_many :playable_hand_entries, dependent: :destroy
  has_many :dealt_hands, through: :deck_list
  belongs_to :tournament_result
  validates_uniqueness_of :tournament_result_id, allow_nil: true
  delegate :colors, to: :deck_list
  delegate :deck_entries, to: :deck_list
  delegate :card_count, to: :deck_list
  delegate :archetype, to: :deck_list
  has_many :deck_entries, through: :deck_list
  has_many :cards, through: :deck_list
  has_many :sideboard_suggestions
  has_many :sideboard_entries
  belongs_to :thumb_print, class_name: "CardPrint"

  accepts_nested_attributes_for :playable_hand_entries

  before_save :set_state
  before_save do
    if thumb_print_id.nil? || (decklist_changed || !deck_list.cards.include?(thumb_print.card))
      self.thumb_print = thumb_print_options.first
    end
  end
  after_save :make_default_clusters
  after_destroy :unset_forking_info

  validates_presence_of :title
  validates_presence_of :author
  validates_presence_of :format
  validates_presence_of :deck_list
  validates_presence_of :avatar

  def thumb_print_options
    deck_list.card_prints.with_thumb
  end

  scope :full_text_search, ->(query) do
    where("match(title) against (? IN NATURAL LANGUAGE MODE)", query) 
  end

  scope :visible_to, lambda { |user|
    if user
      where("public = true or author_id = ?", user.id)
    else
      where("public = true")
    end
  }

  # scope :order_by_last_duel, lambda {
  #   joins(deck_list: [:left_duels,:right_duels])
  #       .select("decks.*, max(greatest(duels.updated_at, right_duels_deck_lists.updated_at)) as last_duel")
  #       .order("last_duel desc")
  #       .group("decks.id")
  # }

  scope :order_by_rating, lambda {
    join_ratings
        .select("decks.*, max(ratings.whr_rating) as max_rating")
        .order("max_rating desc")
        .group("decks.id")
  }

  scope :join_ratings, lambda {
    joins("INNER JOIN deck_lists ON deck_lists.id = decks.deck_list_id INNER JOIN ratings ON ratings.deck_list_id = deck_lists.id and ratings.format_id = decks.format_id")
  }

  scope :by_card, lambda { |card|
    joins(:deck_entries).where(deck_entries: {card_id: card.id})
  }

  scope :legal, lambda {
    joins(:deck_list).
      joins("RIGHT JOIN deck_lists_formats on deck_lists_formats.deck_list_id = deck_lists.id").
      where("deck_lists_formats.format_id = decks.format_id")
  }

  def legal_in_format?
    self.deck_list.legal_in?(self.format)
  end

  def game_count_against(op)
    Game.joins(:duel).where("winning_deck_list_id in (?) and losing_deck_list_id in (?)", [self.id, op.id], [self.id, op.id]).count
  end

  def win_count_against(op)
    Game.joins(:duel).where("winning_deck_list_id = ? and losing_deck_list_id = ?", self.id, op.id).count
  end

  def set_state
    self.public = false unless self.deck_list.enabled
    true
    #self.public = true if self.enabled_changed? && self.enabled
  end

  def disabled_deck_entries
    deck_entries.joins(:card).where(cards: {enabled: false})
  end

  def current_rating
    deck_list.ratings.where(format_id: self.format_id).first
  end

  def games
    Game.where duel_id: duels.select(:id).collect(&:id)
  end

  def make_default_clusters
    if deck_list
      c = self.deck_entry_clusters.where(name: "Lands").first_or_create
      c.deck_entries = deck_list.deck_entries.where(group_type: 'lands')

      deck_list.deck_entries.where.not(group_type: 'lands').group_by{|de| de.card.cmc}.sort_by{|k,v| k}.each do |cmc, des|
        name = "#{cmc}-cost"
        c = self.deck_entry_clusters.where(name: name).first_or_create
        c.deck_entries = des
      end
    end
  end

  def cleanup_clusters
    # todo what is the correct stategy to keep clusters that are still relevant
    self.deck_entry_clusters.each do |clu|
      clu.deck_entries &= self.deck_entries
    end
  end

  def find_result(game)
    return "win" if game.winning_deck_list_id == self.deck_list_id
    return "loss"  if game.losing_deck_list_id == self.deck_list_id
    raise "Not in this duel"
  end

  def won_games
    self.deck_list.won_games
  end

  def to_s
    title
  end
  def title_and_author
    "#{title} (by #{author})"
  end

  def as_json(options= {})
    {
      title: title,
      id: id,
      author: author.to_s,
      avatar: ActionController::Base.helpers.image_url("avatars/#{avatar}"),
      deck_list_id: deck_list_id,
      description: description.to_s,
      formats: [self.format],
      deck_entries: self.deck_entries
    }
  end

  def full_title
    "#{title} #{author.email}"
  end

  def unset_forking_info
    self.forks.update_all(forked_from_id: nil)
  end

  #def get_identifier
    #current_deck_entries.order(:card_id).collect {|r|
      #Base64.strict_encode64("#{[r.amount].pack("C")}#{[r.card_id].pack('S')}")
    #}.join('')
  #end

end
