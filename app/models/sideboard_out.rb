class SideboardOut < ApplicationRecord
  belongs_to :sideboard_plan
  belongs_to :card
  validates_uniqueness_of :card, scope: :sideboard_plan
  validates_numericality_of :amount, greater_than: 0

  validate do
    de = sideboard_plan.deck_list.deck_entries.where(card_id: card.id).first
    if de
      if amount > de.amount
        self.errors.add(:amount, "can't be higher than number of cards in deck list")
      end
    else
      self.errors.add(:card, "can't be a card that is not in the deck")
    end
  end
end
