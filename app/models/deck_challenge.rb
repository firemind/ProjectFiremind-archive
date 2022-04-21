class DeckChallenge < ApplicationRecord
  belongs_to :deck_list
  belongs_to :user
  belongs_to :format
  belongs_to :duel_queue
  belongs_to :winner, class_name: "ChallengeEntry"
  has_many :challenge_entries
  has_many :duels, through: :challenge_entries

  scope :unfinished, -> { where(winner_id: nil) }

  validate do 
    if deck_list && !deck_list.enabled
      errors.add(:deck_list, "has to be playable in Magarena in order for it to be used as a challenge")
    end
    if winner && !challenge_entries.pluck(:id).include?(winner.id)
      errors.add(:winner, "has to be participant")
    end
  end
  validates_presence_of :deck_list, :format, :user

  def current_leader
    leaders =  current_leaders
    if leaders.size == 1
      leaders.first
    else
      nil
    end
  end

  def current_leaders
    with_ratios = challenge_entries.group_by{|r| r.win_ratio}
    highest = with_ratios.keys.max
    with_ratios[highest]
  end

  def closable?
    winner.nil? && challenge_entries.size > 0 && duels_run? && !draw?
  end

  def duels_run?
    duels.where.not(state: 'finished').size == 0
  end
  
  def draw?
    return false if duels.count == 0
    return false unless duels_run?
    return false if challenge_entries.count < 2
    ratios = challenge_entries.map(&:win_ratio).sort.last(2)
    return ratios[0] == ratios[1]
  end
end
