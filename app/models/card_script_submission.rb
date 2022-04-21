class CardScriptSubmission < ApplicationRecord
  belongs_to :card
  belongs_to :user
  validates :card, presence: true, if: ->(r){ !r.is_token }
  validates_presence_of :config
  has_many :duels
  before_save :format_scripts
 # validates_presence_of :user

  def card_name
    card.name if card
  end

  def card_name=(name)
    self.card = Card.where(name: name).first if name && !name.empty?
    self.token_name = name if !card
  end

  def can_be_tested?
    return false if self.is_token
    return false unless self.script.blank?
    return true
  end

  def create_check_duel!(user)
    d1 = Deck.create!(
      title: "Test 1 for CSM #{self.id}",
      format: Format.vintage,
      author: user,
      public: false,
      decklist: "1 #{card.name}"
    )
    duel = self.duels.build(state: :waiting,
                            games_to_play: 0,
                            public: false,
                            deck_list1: d1.deck_list,
                            deck_list2: d1.deck_list,
                            freeform: true,
                            duel_queue_id: DuelQueue.csm_test.id,
                            user: user)
    duel.save!
    return duel
  end

  def check_duel_failed?
    (duel = self.duels.last) && duel.state == 'failed'
  end

  def format_scripts
    if self.config
      self.config.gsub!(/\r/,'')
      self.config.gsub!(/^\s*/,'')
      self.config.gsub!(/^\s*$/,'')
      self.script.gsub!(/^$\n/,'')
    end
    if self.script
      self.script.gsub!(/\r/,'')
      self.script.gsub!(/\t/,'    ')
    end
  end
end
