class DuelQueue < ApplicationRecord
  validates_presence_of :name, :ai1_strength, :ai2_strength, :magarena_version_major, :magarena_version_minor, :life
  validates_uniqueness_of :access_token, if: :user_id

  has_many :duels, :dependent => :restrict_with_error
  belongs_to :user
  has_one :ai_rating_match

  def self.generate_token
    SecureRandom.hex
  end

  def ordered_duels
    duels.
        includes(:format, :user,
                 deck_list1: {archetype: {thumb_print: :edition} },
                 deck_list2: {archetype: {thumb_print: :edition} })
        .order("field(state, #{Duel.states[:started]},#{Duel.states[:failed]},#{Duel.states[:waiting]},#{Duel.states[:finished]}) asc,  created_at desc")
  end

  def self.default
    where(name: 'default', active: true, access_token: nil, user_id: nil).first
  end

  def self.csm_test
    where(name: 'csm-test', active: true).first
  end

  scope :internal, ->(){ where(user_id: nil) }
  scope :active, ->(){ where(active: true) }

  def magarena_version
    "#{magarena_version_major}.#{magarena_version_minor}"
  end

  def redis_name
    "duels#{self.id}"
  end

  def state
    if duels.where(state: 'started').any?
      'started'
    elsif duels.where(state: 'waiting').any?
      'waiting'
    elsif duels.where(state: 'failed').where("requeue_count < 5").any?
      'failed'
    else
      'finished'
    end
  end

  def pop
    $redis.lpop(redis_name)
  end

  def clear
    duels.destroy_all
  end

  def empty_redis
    $redis.del(redis_name)
  end

  def push(duel_id)
    $redis.rpush(redis_name, duel_id)
  end

  def count
    $redis.llen(redis_name)
  end
end
