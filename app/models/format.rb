class Format < ApplicationRecord
  has_many :duels
  has_many :ratings
  has_many :restricted_cards
  accepts_nested_attributes_for :restricted_cards, allow_destroy: true
  has_many :decks
  has_and_belongs_to_many :deck_lists
  has_and_belongs_to_many :editions
  has_many :archetypes
  has_many :meta

  validates_uniqueness_of :name

  scope :enabled, ->() { where(enabled: true) }
  scope :auto_queue, ->() { where(auto_queue: true) }

  def legal_decks
    decks.joins(:deck_list).
      joins("RIGHT JOIN deck_lists_formats on deck_lists_formats.deck_list_id = deck_lists.id").
      where(deck_lists_formats: {format_id: self.id})
  end

  def legal_cards
    Card.where(id: Card.card_ids_at(self.legalities.to_i))
  end

  def legal_card_count
    Card.card_ids_at(self.legalities.to_i).size
  end

  def enabled_legal_card_count
    (Card.enabled.pluck(:id) & Card.card_ids_at(self.legalities.to_i)).size
  end

  def upcoming_card_count
    (Card.added_in_next_release.pluck(:id) & Card.card_ids_at(self.legalities.to_i)).size
  end

  def recalculate_decks
    deck_lists.each do |d|
      FormatCalcWorker.perform_async d.id
    end
  end

  def to_s
    self.name
  end

  def as_json
    {
      id: id,
      name: name
    }
  end

  def no_archetype
    archetypes.where(name: "No Archetype").first_or_create
  end

  def validate_decklist(deckcklist)
  end

  PRIMARY_FORMATS=[:standard, :modern, :legacy, :vintage, :pauper]
  PRIMARY_FORMATS.each do |f|
    define_singleton_method f do
      self.where(name: f.capitalize).first
    end
  end

end
