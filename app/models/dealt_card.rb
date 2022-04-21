class DealtCard < ApplicationRecord
  belongs_to :card

  def to_s
    card.to_s
  end
end
