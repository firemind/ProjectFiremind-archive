class GamesController < ApplicationController
  def index
    @games = Duel.find(params[:duel_id]).games.includes(winning_deck_list: :archetype, losing_deck_list: :archetype)
  end

  def show
    @game = Game.includes(losing_deck_list: :archetype, winning_deck_list: :archetype).find(params[:id])
    @card_name_mappings = (@game.losing_deck_list.deck_entries.includes(:card) + @game.winning_deck_list.deck_entries.includes(:card)).map(&:card).uniq.map{|r| [r.name, r.id]  }.to_h
  end
end
