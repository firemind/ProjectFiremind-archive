require 'rails_helper'

describe "AiRatingMatchesController" do

  describe "POST /ai_rating_matches/" do
    it "adds a new airm" do
      FactoryGirl.create :airm_deck, {deck_list1_id: 1, deck_list2_id: 2, rounds: 3}
      FactoryGirl.create :airm_deck, {deck_list1_id: 3, deck_list2_id: 4, rounds: 5}
      user  = FactoryGirl.create :user, {airm_admin: true}
      user.confirm
      login(user)

      post "/ai_rating_matches/", params: {
        ai_rating_match: {
          ai1_name: "MCTS",
          ai1_identifier: "some-variation",
          ai2_name: "MMAB",
          ai2_identifier: "base",
          ai_strength: 3,
          git_repo: "git@github.com:magarena/magarena.git",
          git_branch: "master",
        }
      }


      expect(302).to eq response.status
      created_airm = assigns("ai_rating_match")

      expect(created_airm.ai_strength).to eq 3
      queue = created_airm.duel_queue
      expect(queue.duels.first.state).to eq 'waiting'
      expect(queue.duels.size).to eq 4
      expect(queue.duels.sum(:games_to_play)).to eq 16
      expect(created_airm.finished?).to eq false


      get "/api/v1/airm/fetch", headers: {
        "Authorization" => "Token token=#{queue.access_token}"
      }

      expect(response.status).to eq 200
      expect(response.body).to include("git clone git@github.com:magarena/magarena.git")
      expect(response.body).to include("git checkout master")
      expect(response.body).to include("ant -f build.xml")
      expect(response.body).to include("ant clean")

    end
  end

end


