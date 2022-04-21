require 'rails_helper'

describe "DeckChallengesController" do
  describe "GET /deck_challenges/new" do
    it "shows duel and games" do

      user  = FactoryGirl.create :user
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      get "/deck_challenges/new", params: { deck_list_id: deck1.deck_list_id }
      expect(response.status).to eq 200
    end
  end
  describe "POST /deck_challenges" do
    it "shows duel and games" do

      user  = FactoryGirl.create :user
      user.confirm
      login(user)
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      deck1.deck_list.make_legal_in(deck1.format)

      expect {
        post "/deck_challenges", params: { 
          deck_challenge: {
            deck_list_id: deck1.deck_list_id,
            format_id: deck1.format.id,
            description: "Test Description"
          }
        }
      }.to change{DeckChallenge.count}.by(1)
      expect(response.status).to eq 302


      dc = DeckChallenge.last
      expect(dc.user).to eq(user)
      expect(dc.deck_list).to eq(deck1.deck_list)
      expect(dc.closable?).to eq(false)
      expect(dc.draw?).to eq(false)


      user2 = FactoryGirl.create :user
      deck2 = FactoryGirl.create :gruul_deck, {author: user2}
      deck2.deck_list.make_legal_in(deck2.format)
      ce1 = participate(dc, user, deck2)
      ce2 = participate(dc, user2, deck2)
      dc.reload


      fake_results(dc, [
        [true,true,true,false,false,true,true,true,false,false],
        [true,true,true,false,false,true,true,true,false,false],
      ])
      expect(ce1.win_ratio).to eq(0.6)
      expect(ce2.win_ratio).to eq(0.6)
      expect(dc.draw?).to eq(true)
      expect(dc.closable?).to eq(false)

      login(user)
      expect {
        post "/deck_challenges/#{dc.id}/run_more"
      }.to change{Duel.count}.by(2)

      expect(dc.draw?).to eq(false)
      expect(dc.closable?).to eq(false)

      fake_results(dc, [
        [true,true,true,false,false,true,true,true,false,false],
        [true,true,true,true,false,true,true,true,true,false]
      ])

      expect(ce1.win_ratio).to eq(0.6)
      expect(ce2.win_ratio).to eq(0.7)
      expect(dc.draw?).to eq(false)
      expect(dc.closable?).to eq(true)

      patch "/deck_challenges/#{dc.id}/close"
      expect(flash[:notice]).to eq 'Deck Challenge was successfully closed.'
      dc = assigns(:deck_challenge)
      expect(dc.winner).to eq(ce2)
      expect(dc.closable?).to eq(false)

      
    end
  end

  def fake_results(dc, results)
    dc.duel_queue.duels.where(state: 'waiting').each_with_index do |duel, idx|
      duel.state = "started"
      duel.save!
      parts = [duel.deck_list1_id, duel.deck_list2_id]
      duel.games_to_play.times do |i|
        winner,loser = results[idx][i] ? parts.reverse : parts
        g = duel.games.build({
          game_number: i,
          play_time_sec: rand(100)+30,
          winning_deck_list_id: winner,
          losing_deck_list_id: loser,
        })
        g.save!
      end
      duel.state = "finished"
      duel.save!
    end
  end

  def participate(dc, user, deck)

    user.confirm
    login(user)

    get "/deck_challenges/#{dc.id}/challenger_select"
    expect(response.status).to eq 200

    expect {
      post "/challenge_entries", params: { 
        challenge_entry: {
          deck_challenge_id: dc.id,
          deck_list_id: deck.deck_list_id
        }
      }
    }.to change{ChallengeEntry.count}.by(1)
    expect(response.status).to eq 302
    expect(flash[:notice]).to eq 'Challenge Entry was successfully created.'

    ce = ChallengeEntry.last
    expect(ce.user).to eq(user)
    expect(ce.deck_challenge).to eq(dc)
    
    duel = Duel.last
    expect(duel.deck_list1).to eq(dc.deck_list)
    expect(duel.deck_list2).to eq(deck.deck_list)

    expect(dc.closable?).to eq(false)
    dc.reload
    dc.challenge_entries.last
  end
end
 
