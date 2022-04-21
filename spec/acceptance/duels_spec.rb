require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Api::V1::Duels" do
  api_header
  post "/api/v1/duels.json" do
    parameter :duel
    parameter :format_name, "Format (standard, modern, etc) in which decks have to be legal", scope: :duel
    parameter :freeform, "If set to true a format is not required and decks will not be checked for legality", scope: :duel
    parameter :deck_list1_id, "ID of first deck list", scope: :duel
    parameter :deck_list2_id, "ID of second deck list", scope: :duel
    parameter :games_to_play, "Number of games the client will play for this duel", scope: :duel
    parameter :public, "List duel publically", scope: :duel

    let(:user){
      user  = FactoryGirl.create :user
      user.generate_access_token!
      user
    }
    let(:deck1){
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      deck1.deck_list.make_legal_in(deck1.format)
      deck1
    }
    let(:deck2){
      deck2 = FactoryGirl.create :gruul_deck, {author: user}
      deck2.deck_list.make_legal_in(deck2.format)
      deck2
    }
    let(:dq){
      FactoryGirl.create :duel_queue, {
        name: "My Custom Queue",
        user: user,
        ai1: "MYAI",
        ai2: "MMAB",
        ai1_strength: 1,
        ai2_strength: 2,
        magarena_version_major: 2,
        magarena_version_minor: 1,
        access_token: DuelQueue.generate_token,
        life: 25
      }
    }
    let(:duel){{
      freeform: true,
      games_to_play: 5,
      deck_list1_id: deck1.deck_list_id,
      deck_list2_id: deck2.deck_list_id,
      public: true
    }}

    let(:raw_post) { params.to_json }
    example "Create a duel in custom queue" do
      header "Authorization", "Token token=#{dq.access_token}"

      do_request

      expect(headers["Accept"]).to eq("application/json")
      expect(status).to eq(201)
    end
  end
end
