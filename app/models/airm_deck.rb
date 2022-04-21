class AirmDeck < ApplicationRecord
  belongs_to :deck_list1, class_name: 'DeckList'
  belongs_to :deck_list2, class_name: 'DeckList'


  def to_s
    "#{deck_list1.to_s} vs #{deck_list2.to_s}"
  end

  def create_duels!(queue,  seed_offset)
    d1 = Duel.new(
      deck_list1: self.deck_list1,
      deck_list2: self.deck_list2,
      freeform: true,
      games_to_play: self.rounds,
      duel_queue_id: queue.id,
      starting_seed: "#{self.id}#{seed_offset}".to_i,
      public: false
    )
    d1.save!
    d2 = Duel.new(
      deck_list1: self.deck_list2,
      deck_list2: self.deck_list1,
      freeform: true,
      games_to_play: self.rounds,
      duel_queue_id: queue.id,
      starting_seed: "#{self.id}#{seed_offset}".to_i,
      public: false
    )
    d2.save!
  end
end
