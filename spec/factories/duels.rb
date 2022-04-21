# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :duel do
    games_to_play 5
    state 'waiting'
    public true
    format_id 1
    duel_queue do
      DuelQueue.default
    end
    factory :duel_with_games do
      after(:create) do |duel, evaluator|
        create_list(:game, duel.games_to_play, duel: duel, winning_deck_list: duel.deck_list1, losing_deck_list: duel.deck_list2)
      end
    end
  end
end
