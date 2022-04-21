class AiRatingMatch < ApplicationRecord

  belongs_to :owner, class_name: "User"
  belongs_to :duel_queue

  delegate :duels, to: :duel_queue

  validates_presence_of :ai1_name, :ai2_name, :ai_strength, :ai1_identifier, :ai2_identifier, :owner
  validate :ai_names_not_equal
  validates :iterations, numericality: { only_integer: true, greater_than: 0, less_than: 6 }

  scope :by_ai_idf, ->(ai, idf){
    where("(ai1_name = ? and ai1_identifier = ?) or (ai2_name = ? and ai2_identifier = ?)", ai, idf, ai, idf)
  }

  scope :by_ai_vs_ai, ->(ai1, ai1_idf, ai2, ai2_idf){
    where(ai1_name: ai1, ai1_identifier: ai1_idf, ai2_name: ai2, ai2_identifier: ai2_idf)
  }

  after_destroy :remove_associated_duels

  def finished?
    (duel_queue.duels.size > 0) && duel_queue.duels.where.not(state: 3).size == 0
  end

  def add_to_redis_queue
    $redis.rpush("airm_jobs", self.api_key)
  end

  def percentage_done
    100.0 * duels.finished.size / duels.size
  end

  def time_spent
    Game.where(duel_id: duels.pluck(:id)).sum("play_time_sec")
  end

  def wins
    state = self.state
    Rails.cache.fetch(['airm_wins', self.id, ['failed', 'finished'].include?(state)? 'done' : state + Time.now.strftime("%Y%m%d%h%M")])do
      duels.wins_by_ai(self.ai1_name)
    end
  end

  def losses
    state = self.state
    Rails.cache.fetch(['airm_losses', self.id, ['failed', 'finished'].include?(state)? 'done' : state + Time.now.strftime("%Y%m%d%h%M")])do
      duels.wins_by_ai(self.ai2_name)
    end
  end

  def wins_by_ai_idf(ai, idf)
    if self.ai1_name == ai && ai1_identifier == idf
      wins
    elsif self.ai2_name == ai && ai2_identifier == idf
      losses
    else
      raise "Ai identifier #{ai} #{idf} not part of AIRM #{self.id}"
    end
  end

  def api_key
    duel_queue.access_token
  end

  def state
    @state ||= calc_state
  end

  private

  def calc_state
    if duels.started.any?
      'started'
    elsif duels.failed.any?
      'failed'
    elsif duels.waiting.count == duels.count
      'new'
    elsif duels.finished.count == duels.count
      'finished'
    else
      'stopped'
    end
  end

  def remove_associated_duels
    duel_queue.clear
  end

  def ai_names_not_equal
    if self.ai1_name == self.ai2_name
      self.errors.add(:ai2_name, "can not be equal to ai1 name")
    end
  end
end
