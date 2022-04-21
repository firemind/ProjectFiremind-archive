class DeckList < ApplicationRecord
  has_many :deck_entries, dependent: :restrict_with_error
  has_many :cards, through: :deck_entries
  has_many :card_prints, through: :cards
  has_many :decks
  has_many :ratings, dependent: :destroy
  has_many :dealt_hands
  has_many :mulligan_decisions, through: :dealt_hands
  has_many :sideboard_plans
  has_many :won_games, foreign_key: :winning_deck_list_id, class_name: "Game"
  has_many :lost_games, foreign_key: :losing_deck_list_id, class_name: "Game"
  has_many :left_duels, foreign_key: :deck_list1_id, class_name: "Duel"
  has_many :right_duels, foreign_key: :deck_list2_id, class_name: "Duel"
  has_and_belongs_to_many :formats, -> { distinct } do
    def << (value)
      super value rescue ActiveRecord::RecordNotUnique
    end
  end
  belongs_to :archetype
  belongs_to :human_archetype, class_name: 'Archetype'
  validates_uniqueness_of :udi
  after_create :calculate_format_legalities
  after_create :assign_archetype
  before_create :set_udi
  before_create :set_enabled
  has_many :format_calc_logs
  validates_presence_of :udi
  attr_accessor :suggested_archetype_name, :format_id
  has_many :deck_challenges
  acts_as_followable

  scope :highest_ranked, ->(format) do
    joins(:ratings).where(ratings: {format_id: format.id}).order("ratings.whr_rating desc")
  end

  validate do
    if archetype && archetype.format.enabled && !self.legal_in?(archetype.format)
      self.errors.add(:archetype_id, "belongs to #{archetype} #{archetype.format} but deck isn't legal there.\n"+as_text)
    end
    if human_archetype && human_archetype.format.enabled && !self.legal_in?(human_archetype.format)
      self.errors.add(:human_archetype_id, "belongs to #{human_archetype} #{human_archetype.format} (human) but deck isn't legal there.\n"+as_text)
    end
  end

  scope :legal_in, ->(format) do
    joins(:formats).where(formats: {id: format})
  end

  scope :nowhere_legal, ->() do
    where("id not in (select distinct deck_list_id from deck_lists_formats)")
  end

  scope :enabled, ->() do
    where(enabled: true)
  end

  def self.get_udi_by_list(list)
    Digest::SHA1.hexdigest(list)
  end

  def calculate_udi
    return nil unless self.deck_entries.size > 0
    DeckList.get_udi_by_list(DeckList.make_deck_list(self))
  end

  def games_count
    won_games_count+lost_games_count
  end

  def self.make_deck_list(dl)
    raise "No deck entries #{dl.id}" if dl.deck_entries.size < 1
    dl.deck_entries.collect(&:to_s).sort.join("")
  end

  def self.containing_card(card_id)
    joins(:deck_entries).group("deck_lists.id").having("count(deck_entries.id) > 0").where(deck_entries: {card_id: card_id})
  end
  
  def mulligan_percentage
    mulligan_decisions.where(mulligan: true).count.to_f / mulligan_decisions.count
  end

  def to_legalities_binary
    dl_card_ids = deck_entries.pluck(:card_id).sort
    Card.full_binary(dl_card_ids)
  end
  
  def to_legalities_array
    dl_card_ids = deck_entries.pluck(:card_id).sort
    Card.sorted_ids.map {|id|
      dl_card_ids.include? id
    }
  end

  def true_indexes
    ind = []
    to_legalities_array.each_with_index {|e, i|
      ind << i if e
    }
    ind
  end

  def matching_indexes(dl2)
    a1 = to_legalities_array
    a2 = dl2.to_legalities_array
    match = []
    [a1.size, a2.size].min.times do |i|
      match << i if a1[i] && a2[i]
    end
    match
  end

  def as_text
    lines = []
    ['creatures', 'spells', 'lands'].each do |type|
      recs = deck_entries.where(group_type: type).joins(:card).order('cards.name ASC').preload(:card)
      if recs.size > 0
        type_lines= recs.collect do |de|
          "#{de.amount} #{de.card.name}"
        end
        type_lines.insert(0, "# #{recs.inject(0){|s,d| s+d.amount}} #{type}")
        type_lines << ''
        lines += type_lines
      end
    end
    others = deck_entries.where(group_type: nil).joins(:card).order('cards.name ASC').collect do |de|
      "#{de.amount} #{de.card}"
    end
    ( lines + others ).join("\r\n")
  end

  def self.find_by_udi(udi)
    self.where(udi: udi).first
  end

  def to_s
    (self.archetype || "No Archetype").to_s
  end

  def existing_or_self
    my_udi = calculate_udi
    dl = DeckList.where(udi: my_udi).first
    return dl || (self.save! && self)
  end

  def card_count
    deck_entries.sum(:amount)
  end

  def land_count
    deck_entries.inject(0){|sum, de| de.group_type == 'lands' ? sum + de.amount : sum }
  end

  def manacurve
    Rails.cache.fetch [:manacurve, self.udi] do
      Hash[deck_entries.joins(:card).where("group_type not like 'lands'").select("sum(amount) as num, cards.cmc").order("cards.cmc").group("cards.cmc").map{|r| [r.cmc, r.num]}]
    end
  end

  def legal_in?(format)
    formats.pluck(:id).include? format.id
  end

  def games
    Game.where("winning_deck_list_id = ? or losing_deck_list_id = ?", self.id, self.id)
  end

  def self.join_games
    joins("INNER JOIN games ON games.winning_deck_list_id = deck_lists.id or games.losing_deck_list_id = deck_lists.id")
  end

  def rating_in(format)
    ratings.where(format_id: format.id).first
  end

  def highest_rating
    ratings.order(:whr_rating).last
  end

  def make_legal_in(format)
    # manually create sql to skip unnecessary transaction created by AR
    sql = "INSERT INTO `deck_lists_formats` (`deck_list_id`, `format_id`) VALUES (#{self.id}, #{format.id})"
    ActiveRecord::Base.connection.execute(sql)
  end

  def duels
    Duel.where("deck_list1_id = ? or deck_list2_id = ?", self.id, self.id)
  end

  def as_magarena_json
    deck = decks.first
    {
      description: deck.description,
      author: deck.author.name,
      link: Rails.application.routes.url_helpers.deck_path(deck, only_path: false),
      rating: self.ratings.first.to_s,
      releaseDate: self.created_at.strftime("%Y%m%d"),
      cards: self.deck_entries.map {|r|
        {
          name: r.card.name,
          quantity: r.amount
        }
      }
    }
  end

  def enabled?
    if self.persisted?
      self.deck_entries.joins(:card).where(cards: {enabled: false}).count == 0
    else
      self.deck_entries.map(&:card).select{|r| !r.enabled}.size == 0
    end
  end

  def games_against_archetype(at)
    games.joins(:winning_deck_list, :losing_deck_list).
        where("(winning_deck_list_id = :myid and losing_deck_lists_games.archetype_id = :opid) or (losing_deck_list_id = :myid and deck_lists.archetype_id = :opid)", myid: self.id, opid: at.id)
  end

  def win_count_against_archetype(at)
    won_games_against_archetype(at).count
  end

  def won_games_against_archetype(at)
    games.joins(:losing_deck_list).where("winning_deck_list_id = ? and deck_lists.archetype_id = ?", self.id, at.id)
  end

  def loss_count_against_archetype(at)
    lost_games_against_archetype(at).count
  end

  def lost_games_against_archetype(at)
    games.joins(:winning_deck_list).where("losing_deck_list_id = ? and deck_lists.archetype_id = ?", self.id, at.id)
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      header_column = ["deck_list_id", "archetype_id", "archetype", "format_id"]
      all_card_ids = self.all.inject([]){|cards,dl| cards | dl.deck_entries.pluck(:card_id)}
      header_column |= all_card_ids
      csv << header_column
      includes(:deck_entries).find_each(batch_size: 10) do |deck_list|
        col = [deck_list.id, deck_list.human_archetype_id, deck_list.human_archetype.to_s, deck_list.human_archetype.format_id]
        all_card_ids.each do |cid|
          de = deck_list.deck_entries.detect{|de| de.card_id == cid}
          col << (de ? de.amount : 0)
        end
        csv << col
      end
    end
  end

  def create_dealt_hand(repeat:1, hand_sizes: [7])
    deck = []
    self.deck_entries.each do |de|
      de.amount.times do
        deck << de.card_id
      end
    end
    repeat.times do
      (hand_sizes).each do |hand_size|
        hand = deck.sample(hand_size)
        dh = DealtHand.create(deck_list_id: self.id)
        hand.each do |card|
          DealtCard.create(
            dealt_hand_id: dh.id,
            card_id: card
          )
        end
      end
    end
  end


  def set_enabled
    self.enabled = self.enabled?
    true
  end

  private

  def set_udi
    self.udi = self.calculate_udi
  end

  def calculate_format_legalities
    FormatCalcWorker.new.process_dl(self, nolog: true)
  end

  def assign_archetype
    AssignArchetypeWorker.new.perform(self.id)
  end

end
