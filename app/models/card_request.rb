class CardRequest < ApplicationRecord
  belongs_to :card
  belongs_to :user
  validates_presence_of :card
  validates_uniqueness_of :card_id
  acts_as_votable

  scope :not_enabled, ->() do
    joins(:card).where(cards: {enabled: false})
  end

  def to_s
    card.to_s
  end

  def close!
    self.state_comment = <<-TEXT
The card has been added now.
    TEXT
    save!
  end

  def card_name
    card.name if card
  end

  def card_name=(name)
    self.card = Card.where(enabled: false, name: name).first if name && !name.empty?
  end


  InitialComment = <<-TEXT
    This request is being evaluated.

    Please consider sending in a Card Script yourself to speed things up.
  TEXT
end
