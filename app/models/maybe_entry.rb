class MaybeEntry < ApplicationRecord
  belongs_to :deck
  belongs_to :card
  belongs_to :deck_entry_cluster

  validates_presence_of :deck, :card, :deck_entry_cluster, :min_amount, :max_amount

  validate :max_amount_not_exceeding, if: ->(r){r.max_amount}
  validate :max_entries_per_deck_not_exceeding, if: ->(r){r.max_amount}
  validate do
    if min_amount && max_amount && min_amount > max_amount
      self.errors.add(:min_amount, "needs to be smaller than max")
    end
  end

  def card_name
    card.name if card
  end

  def card_name=(name)
    self.card = Card.enabled.where(name: name).first if name && !name.empty?
  end

  def to_s
    "#{min_amount} - #{max_amount} #{card_name}"
  end

  def max_amount_not_exceeding
    if max_amount > 4 && (/^Basic Land/ =~ card.card_type) != 0
      self.errors.add(:max_amount, "more than 4 is only allowed for basics")
    end
  end

  def max_entries_per_deck_not_exceeding
    if deck.maybe_entries.where.not(id: self.id).sum(:max_amount) + self.max_amount > 5
      self.errors.add(:max_amount, "deck may have a maximum of 5 replacement cards")
    end
  end

end
