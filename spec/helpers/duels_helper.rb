def add_duel(user, deck1, deck2, wins1, wins2)
  duel = FactoryGirl.create :duel, {
    user: user,
    deck_list1: deck1.deck_list,
    deck_list2: deck2.deck_list,
    games_to_play: wins1+wins2,
    public: true
  }

  wins1.times do
    FactoryGirl.create :game, {
      duel: duel,
      winning_deck_list: deck1.deck_list,
      losing_deck_list: deck2.deck_list
    }
  end

  wins2.times do
    FactoryGirl.create :game, {
      duel: duel,
      winning_deck_list: deck2.deck_list,
      losing_deck_list: deck1.deck_list
    }
  end
  duel.state = 'finished'
  duel.save!
  expect(duel.games_played).to eq wins1+wins2
  expect(duel.wins_deck1).to eq wins1
  expect(duel.state).to eq 'finished'
  return duel
end
