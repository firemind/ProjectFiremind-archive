class SideboardEntry < ApplicationRecord
  belongs_to :card
  belongs_to :deck
  validates_presence_of :card, :deck

  def to_s
    "#{amount}x #{card}"
  end
end
