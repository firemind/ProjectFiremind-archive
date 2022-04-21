class RestrictedCard < ApplicationRecord
  belongs_to :card
  belongs_to :format

  def card_name
    card&.name
  end

  def card_name=(name)
    self.card = Card.where(name: name).first unless name.blank?
  end

  def to_s
    "#{card.name} - #{limit}"
  end
end
