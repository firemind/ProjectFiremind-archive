class DeckEntry < ApplicationRecord
  belongs_to :card
  belongs_to :deck_list
  has_and_belongs_to_many :deck_entry_cluster

  def as_json
    {
      amount: amount,
      card: card.to_s,
      expansion: card.edition.short
    }
  end

  def to_s
    "#{amount}x #{card}"
  end
end
