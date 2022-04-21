class SideboardIn < ApplicationRecord
  belongs_to :sideboard_plan
  belongs_to :card
  validates_uniqueness_of :card, scope: :sideboard_plan
  validates_numericality_of :amount, greater_than: 0

  def to_s
    "+#{amount} #{card}"
  end
end
