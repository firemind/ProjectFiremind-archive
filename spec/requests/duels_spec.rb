require 'rails_helper'

describe "DuelsController" do
  describe "GET /duels/:id" do
    it "shows duel and games" do
      user  = FactoryGirl.create :user
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      deck2 = FactoryGirl.create :gruul_deck, {author: user}

      deck1.deck_list.make_legal_in(deck1.format)
      deck2.deck_list.make_legal_in(deck2.format)

      duel = add_duel(user, deck1, deck2, 3, 2)

      get "/duels/#{duel.id}"

      expect(assigns("duel")).to eq(duel)

      expect(response.status).to eq 200

     

    end
  end
  describe "GET /duels/new" do
    it "shows duel form" do
      user  = FactoryGirl.create :user
      user.confirm
      login(user)
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      deck2 = FactoryGirl.create :gruul_deck, {author: user}

      deck1.deck_list.make_legal_in(deck1.format)
      deck2.deck_list.make_legal_in(deck2.format)

      get "/duels/new"

      expect(response.status).to eq 200
      expect(assigns("formats")).to eq(Format.enabled)
      expect(assigns("available_decks")).to eq(assigns("formats").map{ |format| [format.to_s, format.decks.order("title").visible_to(user).map { |deck| [deck.title_and_author, deck.deck_list_id] }]})

      expect(response.body).to include("<h1>Run a new Duel</h1>")

    end
  end

  describe "POST /duels/" do
    it "adds a new duel" do
      user  = FactoryGirl.create :user
      user.confirm
      login(user)
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      deck2 = FactoryGirl.create :gruul_deck, {author: user}

      deck1.deck_list.make_legal_in(deck1.format)
      deck2.deck_list.make_legal_in(deck2.format)

      get "/duels/new"

      expect(response.status).to eq 200
      expect(assigns("formats")).to eq(Format.enabled)
      expect(assigns("available_decks")).to eq(assigns("formats").map{ |format| [format.to_s, format.decks.order("title").visible_to(user).map { |deck| [deck.title_and_author, deck.deck_list_id] }]})

      expect(response.body).to include("<h1>Run a new Duel</h1>")

    end
  end

end
