require 'rails_helper'

describe "Main" do
  describe "GET /" do
    it "Shows last 6 public duels" do
      user  = FactoryGirl.create :user
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      deck2 = FactoryGirl.create :gruul_deck, {author: user}

      deck1.deck_list.make_legal_in(deck1.format)
      deck2.deck_list.make_legal_in(deck2.format)


      DuelQueue.default.empty_redis

      add_duel(user, deck1, deck2, 2, 3)
      add_duel(user, deck1, deck2, 0, 5)
      add_duel(user, deck1, deck2, 1, 4)
      duel = add_duel(user, deck1, deck2, 3, 2)
      duel.state = 'started'
      duel.save!

      expect(DuelQueue.default.count).to eq 4
      expect(Duel.count).to eq 4

      get "/"

      expect(assigns("duel_queue")).to eq(DuelQueue.default)

      expect(response.status).to eq 200

      expect(response.body).to include("<h3>Recent Duels</h3>")
      expect(response.body).to include("#{deck1.deck_list.to_s}")
      expect(response.body).to include('<span class="losing">2</span>')

    end
    it "Works with log in" do
      user  = FactoryGirl.create :user
      user.confirm
      login(user)
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      deck2 = FactoryGirl.create :gruul_deck, {author: user}

      deck1.deck_list.make_legal_in(deck1.format)
      deck2.deck_list.make_legal_in(deck2.format)


      DuelQueue.default.empty_redis

      add_duel(user, deck1, deck2, 2, 3)
      add_duel(user, deck1, deck2, 0, 5)
      add_duel(user, deck1, deck2, 1, 4)
      duel = add_duel(user, deck1, deck2, 3, 2)

      expect(DuelQueue.default.count).to eq 4
      expect(Duel.count).to eq 4

      get "/"

      expect(response.status).to eq 200

      expect(response.body).to include("<h3>Recent Duels</h3>")

    end
  end
end

