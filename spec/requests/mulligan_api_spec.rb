require 'rails_helper'

describe "Mulligan API" do
  describe "GET /api/v1/mulligans/hands.json" do
    include CardHelper
    it "gets all public hand ids" do

      user  = FactoryGirl.create :user
      deck1 = FactoryGirl.create :naya_deck, author: user, public: true
      deck2 = FactoryGirl.create :gruul_deck, author: user, public: true
      private_deck = FactoryGirl.create :delver_deck, author: user, public: false

      expect(private_deck.public).to eq false
      expect(deck1.deck_list_id).to_not eq(deck2.deck_list_id)

      deck1.deck_list.create_dealt_hand
      deck2.deck_list.create_dealt_hand
      private_deck.deck_list.create_dealt_hand

      deck1.deck_list.make_legal_in(deck1.format)
      deck2.deck_list.make_legal_in(deck2.format)
      
      post "/api/v1/mulligans/hand/#{deck1.dealt_hands.first.id}/mulligan.json", params: {draw: false}, headers: { "Accept" => "application/json" }
      post "/api/v1/mulligans/hand/#{deck1.dealt_hands.first.id}/mulligan.json", params: {draw: false}, headers: { "Accept" => "application/json" }
      post "/api/v1/mulligans/hand/#{deck1.dealt_hands.first.id}/keep.json", params: {draw: false}, headers: { "Accept" => "application/json" }

      post "/api/v1/mulligans/hand/#{deck2.dealt_hands.first.id}/mulligan.json", params: {draw: false}, headers: { "Accept" => "application/json" }
      post "/api/v1/mulligans/hand/#{deck2.dealt_hands.first.id}/mulligan.json", params: {draw: false}, headers: { "Accept" => "application/json" }

      get "/api/v1/mulligans/established_hands.json?limit=100"

      #get "/api/v1/hands.json", {}, {
        #"Accept" => "application/json",
        #"Authorization" => "Token token=#{user.access_token}"
      #}

      expect(response.status).to eq 200

      body = JSON.parse(response.body)

      expect(body["hands"].size).to eq(1)
      [deck1.dealt_hands.first].each do |hand|
        expect_json_for(body["hands"], hand)
      end
      expect(body["hands"].map{|r| r['id']}).to_not include(deck2.dealt_hands.first.id)
      expect(body["hands"].map{|r| r['id']}).to_not include(private_deck.dealt_hands.first.id)
    end

    it "get established public hand ids" do

      user  = FactoryGirl.create :user
      deck1 = FactoryGirl.create :naya_deck, author: user, public: true
      deck2 = FactoryGirl.create :gruul_deck, author: user, public: true
      private_deck = FactoryGirl.create :delver_deck, author: user, public: false

      expect(private_deck.public).to eq false
      expect(deck1.deck_list_id).to_not eq(deck2.deck_list_id)

      deck1.deck_list.create_dealt_hand
      deck2.deck_list.create_dealt_hand
      private_deck.deck_list.create_dealt_hand

      deck1.deck_list.make_legal_in(deck1.format)
      deck2.deck_list.make_legal_in(deck2.format)

      get "/api/v1/mulligans/hands.json?limit=100"

      #get "/api/v1/hands.json", {}, {
        #"Accept" => "application/json",
        #"Authorization" => "Token token=#{user.access_token}"
      #}

      expect(response.status).to eq 200

      body = JSON.parse(response.body)

      expect(body["hands"].size).to eq(82)
      [deck1.dealt_hands.first, deck2.dealt_hands.first].each do |hand|
        expect_json_for(body["hands"], hand)
      end
      expect(body["hands"].map{|r| r['id']}).to_not include(private_deck.dealt_hands.first.id)
    end

    def expect_json_for(hands, hand)
      expect(hands).to include({
        "id" => hand.id,
        "deck_list_id" => hand.deck_list_id,
        "mulligan_count" => hand.mulligan_count,
        "keep_count" => hand.keep_count,
        "cards" => hand.dealt_cards.map {|r|{
          "id" => r.id,
          "card" => {
            "id" => r.card.id,
            "name" => r.card.name,
            "image" => card_image_url(r.card.primary_print)
          }
        }}
      })
    end

    it "gets hand ids for specific public deck" do
      user  = FactoryGirl.create :user
      user.generate_access_token!
      user2  = FactoryGirl.create :user, email: "dinglething@firemind.ch"
      user2.generate_access_token!

      deck1 = FactoryGirl.create :naya_deck, author: user, public: true
      deck2 = FactoryGirl.create :gruul_deck, author: user, public: true
      deck1.deck_list.create_dealt_hand
      deck2.deck_list.create_dealt_hand

      get "/api/v1/mulligans/decks/#{deck1.deck_list_id}/hands.json?limit=100", headers: {
        "Accept" => "application/json",
        "Authorization" => "Token token=#{user2.access_token}"
      }

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect_json_for(body["hands"], deck1.dealt_hands.first)
      expect(body["hands"].map{|r| r['id']}).to_not include(deck2.dealt_hands.first.id)
    end

    it "gets hand ids for specific private deck with auth" do
      user  = FactoryGirl.create :user
      user.generate_access_token!
      deck1 = FactoryGirl.create :naya_deck, author: user, public: false
      deck2 = FactoryGirl.create :gruul_deck, author: user, public: false
      deck1.deck_list.create_dealt_hand
      deck2.deck_list.create_dealt_hand
      get "/api/v1/mulligans/decks/#{deck1.deck_list_id}/hands.json?limit=100", headers: {
        "Accept" => "application/json",
        "Authorization" => "Token token=#{user.access_token}"
      }

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect_json_for(body["hands"], deck1.dealt_hands.first)
      expect(body["hands"].map{|r| r['id']}).to_not include(deck2.dealt_hands.first.id)
    end

    it "gets hand ids for specific private deck with auth and no hands" do
      user  = FactoryGirl.create :user
      user.generate_access_token!
      deck1 = FactoryGirl.create :naya_deck, author: user, public: false
      deck2 = FactoryGirl.create :gruul_deck, author: user, public: false
      get "/api/v1/mulligans/decks/#{deck1.deck_list_id}/hands.json", headers: {
        "Accept" => "application/json",
        "Authorization" => "Token token=#{user.access_token}"
      }

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect(body["hands"].size).to eq(10)

      get "/api/v1/mulligans/decks/#{deck1.deck_list_id}/hands.json?limit=100", headers: {
        "Accept" => "application/json",
        "Authorization" => "Token token=#{user.access_token}"
      }
      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect_json_for(body["hands"], deck1.dealt_hands.first)
      expect(body["hands"].size).to eq(80)


    end

    it "does not get hand ids for specific private deck without auth" do
      user  = FactoryGirl.create :user
      deck1 = FactoryGirl.create :naya_deck, author: user, public: false
      deck2 = FactoryGirl.create :gruul_deck, author: user, public: false
      deck1.deck_list.create_dealt_hand
      deck2.deck_list.create_dealt_hand
      get "/api/v1/mulligans/decks/#{deck1.deck_list_id}/hands.json"
      expect(response.status).to eq 401

      expect(response.body).to_not include("hands")
    end

  end

  describe "GET /api/v1/mulligans/hand/:id/keep.json" do
    it "logs keep decision" do
      user  = FactoryGirl.create :user
      user.generate_access_token!
      deck1 = FactoryGirl.create :naya_deck, author: user, public: false
      deck1.deck_list.create_dealt_hand
      hand = deck1.dealt_hands.first
      expect(hand.mulligan_decisions.count).to eq(0)
      post "/api/v1/mulligans/hand/#{hand.id}/keep.json", params: {draw: true}, headers: {
        "Accept" => "application/json"
      }
      expect(response.status).to eq 200
      expect(hand.mulligan_decisions.count).to eq(1)
      expect(hand.mulligan_decisions.last.mulligan).to eq(false)
      expect(hand.mulligan_decisions.last.draw).to eq(true)

      post "/api/v1/mulligans/hand/#{hand.id}/keep.json", params: {draw: false}, headers: {
        "Accept" => "application/json"
      }
      expect(response.status).to eq 200
      expect(hand.mulligan_decisions.count).to eq(2)
      expect(hand.mulligan_decisions.last.mulligan).to eq(false)
      expect(hand.mulligan_decisions.last.draw).to eq(false)

    end
    it "logs authenticated keep decision" do
      user  = FactoryGirl.create :user
      user.generate_access_token!
      deck1 = FactoryGirl.create :naya_deck, author: user, public: false
      deck1.deck_list.create_dealt_hand
      hand = deck1.dealt_hands.first
      expect(hand.mulligan_decisions.count).to eq(0)
      post "/api/v1/mulligans/hand/#{hand.id}/keep.json", params: {draw: true}, headers: {
        "Accept" => "application/json"
      }
      expect(response.status).to eq 200
      expect(hand.mulligan_decisions.count).to eq(1)
      expect(hand.mulligan_decisions.last.mulligan).to eq(false)
      expect(hand.mulligan_decisions.last.draw).to eq(true)

      post "/api/v1/mulligans/hand/#{hand.id}/keep.json", params: {draw: false}, headers: {
        "Accept" => "application/json",
        "Authorization" => "Token token=#{user.access_token}"
      }
      expect(response.status).to eq 200
      expect(hand.mulligan_decisions.count).to eq(2)
      expect(hand.mulligan_decisions.last.mulligan).to eq(false)
      expect(hand.mulligan_decisions.last.draw).to eq(false)
      expect(hand.mulligan_decisions.last.user).to eq(user)

    end
  end
  describe "GET /api/v1/mulligans/hand/:id/mulligan.json" do
    it "logs mulligan decision" do
      user  = FactoryGirl.create :user
      user.generate_access_token!
      deck1 = FactoryGirl.create :naya_deck, author: user, public: false
      deck1.deck_list.create_dealt_hand
      hand = deck1.dealt_hands.first
      expect(hand.mulligan_decisions.count).to eq(0)
      post "/api/v1/mulligans/hand/#{hand.id}/mulligan.json", params: {draw: true}, headers: {
        "Accept" => "application/json"
      }
      expect(response.status).to eq 200
      expect(hand.mulligan_decisions.count).to eq(1)
      expect(hand.mulligan_decisions.last.mulligan).to eq(true)
      expect(hand.mulligan_decisions.last.draw).to eq(true)

      post "/api/v1/mulligans/hand/#{hand.id}/mulligan.json", params: {draw: false}, headers: {
        "Accept" => "application/json"
      }
      expect(response.status).to eq 200
      expect(hand.mulligan_decisions.count).to eq(2)
      expect(hand.mulligan_decisions.last.mulligan).to eq(true)
      expect(hand.mulligan_decisions.last.draw).to eq(false)

    end
    it "recommends next hand" do
      user  = FactoryGirl.create :user
      user.generate_access_token!
      deck1 = FactoryGirl.create :naya_deck, author: user, public: false
      deck1.deck_list.create_dealt_hand(hand_sizes: [6,7])
      hand6 = deck1.dealt_hands.first
      hand = deck1.dealt_hands.last
      expect(hand.mulligan_decisions.count).to eq(0)
      post "/api/v1/mulligans/hand/#{hand.id}/mulligan.json", params: {draw: true}, headers: {
        "Accept" => "application/json"
      }
      expect(response.status).to eq 200
      expect(hand.mulligan_decisions.count).to eq(1)
      expect(hand.mulligan_decisions.last.mulligan).to eq(true)
      expect(hand.mulligan_decisions.last.draw).to eq(true)

      body = JSON.parse(response.body)
      expect(body['next']).to eq(hand6.id)
      expect(body['draw']).to eq("true")

      post "/api/v1/mulligans/hand/#{hand.id}/mulligan.json", params: {draw: false}, headers: {
        "Accept" => "application/json"
      }
      expect(response.status).to eq 200
      expect(hand.mulligan_decisions.count).to eq(2)
      expect(hand.mulligan_decisions.last.mulligan).to eq(true)
      expect(hand.mulligan_decisions.last.draw).to eq(false)

      body = JSON.parse(response.body)
      expect(body['next']).to eq(hand6.id)
      expect(body['draw']).to eq("false")

    end
  end
  describe "GET /api/v1/mulligans/decks.json" do
    it "restricts access to private decks" do
      user  = FactoryGirl.create :user
      user.generate_access_token!

      deck1 = FactoryGirl.create :naya_deck, author: user, public: false
      deck2 = FactoryGirl.create :gruul_deck, author: user, public: false
      deck1.deck_list.create_dealt_hand
      deck2.deck_list.create_dealt_hand
      hand = deck1.dealt_hands.first
      get "/api/v1/mulligans/decks.json", headers: {
        "Accept" => "application/json",
        "Authorization" => "Token token=#{user.access_token}"
      }

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect(body['decks'].size).to eq(2)
    end
  end
end
