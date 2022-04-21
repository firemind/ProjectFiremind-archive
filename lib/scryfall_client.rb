require 'rest-client'
require 'json'
class ScryfallClient
  @@base_url = "https://api.scryfall.com/"


  def get_set(short)
    resp = RestClient.get "#{@@base_url}sets/#{short}"
    JSON.parse resp
  end

  def cards_by_set(short)
    set_code = short.downcase
    set = get_set(set_code)
    list=[]
    set['card_count'].to_i.times do |i|
      resp = RestClient.get "#{@@base_url}cards/#{set_code}/#{i+1}"
      list << JSON.parse(resp)
      sleep 0.05
    end
    list
  end

  def cards
    page = 1
    count = nil
    finished = false
    while !finished
      resp = RestClient.get "#{@@base_url}cards", {page: page}
      data = JSON.parse resp
      count ||= data['total_cards'] 
      finished = !data['has_more'] 

      data['data'].each do |card|
        yield card
      end
      sleep 0.05
    end
    puts "Missing #{count_cards}"
  end


  #def pop_duel
    #resp = RestClient.delete "#{@@base_url}duel_jobs", auth_header
    #JSON.parse resp
  #end

  #def post_game(duel_id, game={})
    #p = {
      #game_number: 1,
      #play_time: 150,
      #win_deck1: true,
      #magarena_version_major: 1,
      #magarena_version_minor: 666,
      #log: "the game log ä"
    #}.merge(game)
    #resp = RestClient.post "#{@@base_url}duel_jobs/#{duel_id}/games", p, auth_header
    #JSON.parse resp
  #end

  #def post_success(duel_id)
    #resp = RestClient.post "#{@@base_url}duel_jobs/#{duel_id}/post_success", p, auth_header
    #JSON.parse resp
  #end

  #def post_failure(duel_id)
    #resp = RestClient.post "#{@@base_url}duel_jobs/#{duel_id}/post_failure", p, auth_header
    #JSON.parse resp
  #end
  #def auth_header
    #{
      #"Accept" => "application/json",
      #"Authorization" => "Token token=#{@@token}"
    #}
  #end

  private
end
