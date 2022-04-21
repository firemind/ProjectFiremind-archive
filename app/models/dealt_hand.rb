class DealtHand < ApplicationRecord
  belongs_to :deck_list
  has_many :dealt_cards
  has_many :mulligan_decisions

  scope :by_card_count, ->(count){
    select("dealt_hands.*, count(dealt_cards.id) as card_count").
    joins(:dealt_cards).
    having("card_count = ?", count).
    group("dealt_hands.id")
  }

  scope :by_least_decisions, ->(){
    joins("LEFT JOIN mulligan_decisions ON dealt_hands.id = mulligan_decisions.dealt_hand_id").
    order("count(mulligan_decisions.id), rand()").group("dealt_hands.id")
  }

  scope :decisions_at_least, ->(count){
    joins("LEFT JOIN mulligan_decisions ON dealt_hands.id = mulligan_decisions.dealt_hand_id").
    having("count(mulligan_decisions.id) >= ?", count).order("rand()").group("dealt_hands.id")
  }

  def mulligan_count
    mulligan_decisions.where(mulligan: true).count
  end

  def keep_count
    mulligan_decisions.where(mulligan: false).count
  end

  def as_json(params={})
    {
      cards: dealt_cards.map(&:card_id).sort,
      deck_list: deck_list_id,
      #TODO separate play and draw
      mulligan: mulligan_decisions.to_a.select{|m| m.mulligan}.size.to_f / mulligan_decisions.size
    }
  end

  def mean_mulligan_value
    if (total = mulligan_decisions.size) > 0
      mulligan_decisions.to_a.select{|m| m.mulligan}.size.to_f / total
    else
      0
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["deck_list_id", "mulligan_value", "num_lands", "num_cards", "num_1_drop", "num_2_drop", "num_3_drop", "num_4_drop"]
      all.each do |dealt_hand|
        mull_value = dealt_hand.mean_mulligan_value
        num_lands = dealt_hand.num_lands
        num_cards = dealt_hand.dealt_cards.count
        csv << [
          dealt_hand.deck_list_id,
          mull_value,
          num_lands,
          num_cards,
          dealt_hand.num_n_drop(1),
          dealt_hand.num_n_drop(2),
          dealt_hand.num_n_drop(3),
          dealt_hand.num_n_drop(4)
        ]
      end
    end
  end

  def num_lands
    count = 0
    dealt_cards.each do |dc|
      if /(Basic |Snow )?Land( - .*)?/i.match dc.card.card_type
        count+=1
      end
    end
    count
  end
  def num_n_drop(n)
    count = 0
    dealt_cards.each do |dc|
      if dc.card.cmc == n
        count+=1
      end
    end
    count
  end

  def agrees_with_magarena?
  end

  def magarena_decision
  end
  #def self.to_csv(options = {})
    #CSV.generate(options) do |csv|
      #all.each do |dealt_hand|
        #cids = dealt_hand.dealt_cards.map(&:card_id)
        #mull_value = dealt_hand.mulligan_decisions.to_a.select{|m| m.mulligan}.size.to_f / dealt_hand.mulligan_decisions.size
        #unless (0.5-mull_value).abs > 0.2
          #next
        #end
        #cids.permutation.to_a.each do |p|
          #col = p
          #col.fill(0, col.length..6)
          #col << dealt_hand.deck_list_id
          #col << mull_value.round
          #csv << col
        #end
      #end
    #end
  #end
end
