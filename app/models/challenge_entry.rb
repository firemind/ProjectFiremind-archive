class ChallengeEntry < ApplicationRecord
  belongs_to :deck_challenge
  belongs_to :deck_list
  belongs_to :user
  has_many :duels
  has_many :games, through: :duels

  validates_uniqueness_of :user, scope: :deck_challenge

  validate do
    if deck_list && deck_list == deck_challenge&.deck_list
      self.errors.add(:deck_list, "can't be equal to challenge deck")
    end
  end


  def win_ratio
    gc = games.count
    if gc > 0
      games.where(winning_deck_list_id: self.deck_list_id).count.to_f / gc
    else
      0
    end
  end

  def create_duel
    self.duels.create!(
      deck_list1_id: deck_challenge.deck_list_id,
      deck_list2_id: self.deck_list_id,
      duel_queue_id:    deck_challenge.duel_queue_id,
      games_to_play: 10,
      user: user,
      format: deck_challenge.format
    )
  end
end
