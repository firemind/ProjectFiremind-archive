require 'rest-client'
require 'json'
class SimApi
  #@@base_url = "https://www.firemind.ch/api/v1/"
  @@base_url = "http://firemind.local/api/v1/"
  #@@token = "4fe3925f1751c625cec886108adb2cfc"
  @@token = "bd0757866bfe88cee8c5f632caf2238b"


  def pop_duel
    resp = RestClient.delete "#{@@base_url}duel_jobs", auth_header
    JSON.parse resp
  end

  def post_game(duel_id, game={})
    p = {
      game_number: 1,
      play_time: 150,
      win_deck1: true,
      magarena_version_major: 1,
      magarena_version_minor: 666,
      log: "the game log ä"
    }.merge(game)
    resp = RestClient.post "#{@@base_url}duel_jobs/#{duel_id}/games", p, auth_header
    JSON.parse resp
  end

  def post_success(duel_id)
    resp = RestClient.post "#{@@base_url}duel_jobs/#{duel_id}/post_success", p, auth_header
    JSON.parse resp
  end

  def post_failure(duel_id)
    resp = RestClient.post "#{@@base_url}duel_jobs/#{duel_id}/post_failure", p, auth_header
    JSON.parse resp
  end
  def auth_header
    {
      "Accept" => "application/json",
      "Authorization" => "Token token=#{@@token}"
    }
  end

  private
end

while true
  client = SimApi.new
  duel = client.pop_duel
  puts duel.inspect
  sleep 2
  duel["games_to_play"].times do
    client.post_game(duel["id"])
    sleep 2
  end
  if rand(2)==0
    client.post_success(duel["id"])
  else
    client.post_failure(duel["id"])
  end
end
