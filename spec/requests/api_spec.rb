require 'rails_helper'

describe "AI Job API" do
  describe "DELETE /api/ai_jobs/" do
    it "pops ai job from queue" do

      user  = FactoryGirl.create :user
      user.generate_access_token!
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      deck2 = FactoryGirl.create :gruul_deck, {author: user}

      expect(deck1.deck_list_id).to_not eq(deck2.deck_list_id)

      deck1.deck_list.make_legal_in(deck1.format)
      deck2.deck_list.make_legal_in(deck2.format)

      DuelQueue.default.empty_redis
      expect(DuelQueue.default.count).to eq 0

      duel = FactoryGirl.create :duel, {
        user: user,
        deck_list1: deck1.deck_list,
        deck_list2: deck2.deck_list,
        games_to_play: 3
      }

      expect(DuelQueue.default.count).to eq 1
      expect(Duel.count).to eq 1

      pop_duel(user.access_token)

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect(body["state"]).to eq "started"
      expect(body["games_to_play"]).to eq 3
      expect(body["deck1_text"]).to eq deck1.deck_list.as_text
      expect(body["deck2_text"]).to eq deck2.deck_list.as_text
      expect(body["id"]).to eq duel.id

      post_game(duel.id,{
        game_number: 1,
        play_time: "01 Jan 1970 00:02:42 GMT",
        win_deck1: true,
        magarena_version_major: 1,
        magarena_version_minor: 666,
        log: "the game log ä"
      },user.access_token)
      expect(response.status).to eq 200

      duel.reload
      expect(duel.games.count).to eq 1
      expect(duel.games_played).to eq 1
      expect(duel.wins_deck1).to eq 1
      expect(duel.games.first.play_time.strftime("%H:%M:%S")).to eq("00:02:42")

      post_game(duel.id,{
        game_number: 2,
        play_time: "01 Jan 1970 00:01:45 GMT",
        win_deck1: false,
        magarena_version_major: 1,
        magarena_version_minor: 666,
        log: "logentries"
      },user.access_token)
      expect(response.status).to eq 200

      contents = File.read(LOGFILE_BASEDIR+duel.games.last.log_path)
      expect(contents).to eq "logentries"

      duel.reload
      expect(duel.games.count).to eq 2
      expect(duel.games_played).to eq 2
      expect(duel.wins_deck1).to eq 1
      expect(duel.state).to eq "started"

      post_game(duel.id, {
        game_number: 3,
        play_time: "01 Jan 1970 00:01:25 GMT",
        win_deck1: true,
        magarena_version_major: 1,
        magarena_version_minor: 666,
        log: "logentries"
      },user.access_token)
      expect(response.status).to eq 200

      duel.reload
      expect(duel.games.count).to eq 3
      expect(duel.games_played).to eq 3
      expect(duel.games_to_play).to eq 3
      expect(duel.wins_deck1).to eq 2
      expect(duel.state).to eq "started"

      post_duel_success(duel.id, user.access_token)
      expect(response.status).to eq 200
      duel.reload
      expect(duel.state).to eq "finished"

      post_game(duel.id, {
        game_number: 4,
        play_time: "01 Jan 1970 00:01:25 GMT",
        win_deck1: true,
        magarena_version_major: 1,
        magarena_version_minor: 666,
        log: "böp".encode("iso-8859-1")
      },user.access_token)
      expect(response.status).to eq 422

    end
    it "pops script check job from queue" do
      user  = FactoryGirl.create :user, {sysuser: true}
      user.generate_access_token!

      csm_queue = FactoryGirl.create(:duel_queue, user: user, name: 'csm-test', access_token: DuelQueue.generate_token)
      csm_queue.empty_redis
      expect(csm_queue.count).to eq 0

      csm  = FactoryGirl.create :card_script_submission, {card: Card.first}
      csm.create_check_duel!(user)

      expect(csm_queue.count).to eq 1
      expect(csm_queue.count).to eq 1
      expect(Duel.count).to eq 1

      pop_duel(csm_queue.access_token)

      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['card_scripts']).to eq [{"name" => Card.first.name, "config" => csm.config, "script" => ""}] # does not return script currently because of security risks with running unconstrained groovy code

    end
    it "pops ai job from custom duel queue" do

      user  = FactoryGirl.create :user
      user.generate_access_token!
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      deck2 = FactoryGirl.create :gruul_deck, {author: user}

      deck1.deck_list.make_legal_in(deck1.format)
      deck2.deck_list.make_legal_in(deck2.format)

      dq = FactoryGirl.create :duel_queue, {
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
      expect(dq.count).to eq 0

      duel = FactoryGirl.create :duel, {
        user: user,
        duel_queue: dq,
        deck_list1: deck1.deck_list,
        deck_list2: deck2.deck_list,
        games_to_play: 3
      }

      expect(dq.count).to eq 1
      expect(Duel.count).to eq 1

      pop_duel(dq.access_token)

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect(body["state"]).to eq "started"
      expect(body["games_to_play"]).to eq 3
      expect(body["ai1"]).to eq "MYAI"
      expect(body["ai2"]).to eq "MMAB"
      expect(body["str_ai1"]).to eq 1
      expect(body["str_ai2"]).to eq 2
      expect(body["life"]).to eq 25
      expect(body["deck1_text"]).to eq deck1.deck_list.as_text
      expect(body["deck2_text"]).to eq deck2.deck_list.as_text
      expect(body["id"]).to eq duel.id

      post_game(duel.id, {
        game_number: 1,
        play_time: "01 Jan 1970 00:02:05 GMT",
        win_deck1: true,
        magarena_version_major: 1,
        magarena_version_minor: 666,
        log: "the game log ä"
      },dq.access_token)
      expect(response.status).to eq 200

      duel.reload
      expect(duel.games.count).to eq 1
      expect(duel.games_played).to eq 1
      expect(duel.wins_deck1).to eq 1

      post_game(duel.id, {
        game_number: 2,
        play_time: "01 Jan 1970 00:02:42 GMT",
        win_deck1: false,
        magarena_version_major: 1,
        magarena_version_minor: 666,
        log: "logentries"
      }, dq.access_token)
      expect(response.status).to eq 200

      contents = File.read(LOGFILE_BASEDIR+duel.games.last.log_path)
      expect(contents).to eq "logentries"

      duel.reload
      expect(duel.games.count).to eq 2
      expect(duel.games_played).to eq 2
      expect(duel.wins_deck1).to eq 1
      expect(duel.state).to eq "started"

      post_game(duel.id, {
        game_number: 3,
        play_time: "01 Jan 1970 00:02:42 GMT",
        win_deck1: true,
        magarena_version_major: 1,
        magarena_version_minor: 666,
        log: "logentries"
      }, dq.access_token)
      expect(response.status).to eq 200

      duel.reload
      expect(duel.games.count).to eq 3
      expect(duel.games_played).to eq 3
      expect(duel.games_to_play).to eq 3
      expect(duel.wins_deck1).to eq 2
      expect(duel.state).to eq "started"

      post_duel_success(duel.id, dq.access_token)
      expect(response.status).to eq 200
      duel.reload
      expect(duel.state).to eq "finished"

    end

  end

  def pop_duel(token)
      delete "/api/v1/duel_jobs", params:{}, headers:{
        "Accept" => "application/json",
        "Authorization" => "Token token=#{token}"
      }
  end
  def post_game(duel_id, params, token)
    post "/api/v1/duel_jobs/#{duel_id}/games", params: params, headers: {
      "Accept" => "application/json",
      "Authorization" => "Token token=#{token}"
    }
  end
  
  def post_duel_success(duel_id, token)
    post "/api/v1/duel_jobs/#{duel_id}/post_success", params:{
    }, headers:{
      "Accept" => "application/json",
      "Authorization" => "Token token=#{token}"
    }
  end
end
