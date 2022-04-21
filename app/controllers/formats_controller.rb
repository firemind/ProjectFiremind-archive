class FormatsController < ApplicationController
  before_action :set_record, only: [:show, :cards, :deck_lists, :decks, :editions, :restricted_cards, :top_ratings_chart_data, :top_cards]

  def show
    @top_decks = Rating.highest_in(@format).includes(deck_list: {archetype: {thumb_print: :edition}}).limit(10).map {|rating| rating.deck_list}
    @archetypes = Rails.cache.fetch ["archetypes_with_most_games", @format.id], expires_in: 1.hour do
      @format.archetypes.ordered_by_num_games.limit(10).sort_by{|r| -r.name.length}
    end
    @archetype_matchups = Rails.cache.fetch ["archetype_matchups", *@archetypes.map(&:id).sort], expires_in: 1.hour do
      matchups = {}
      @archetypes.each_with_index do |at,i|
        matchups[at] ||= {}
        @archetypes.each do |other|
          win_perc,win_count,loss_count= nil
          if at == other
            win_count= loss_count = at.win_count_against(other)
          elsif m = matchups.dig(other,at)
            win_count = m[:loss_count]
            loss_count = m[:win_count]
            v = 1.0 - m[:win_perc] if m[:win_perc]
          else
            win_count  = at.win_count_against(other)
            loss_count = at.loss_count_against(other)
            v = if loss_count > 0
              if win_count > 0
                win_count.to_f / (win_count+loss_count)
              else
                0.0
              end
            else
              if win_count > 0
                1.0
              else
                nil
              end
            end
          end
          matchups[at][other] = {win_perc: v, win_count: win_count, loss_count: loss_count}
        end
      end
      matchups
    end
  end

  def cards
    @cards = @format.legal_cards.order(:name).page(params[:page]).per(9)
  end

  def top_cards
    @cards = @format.legal_cards.order("magarena_rating desc").first(20)
  end

  def deck_lists
    @deck_lists = DeckList.where(human_archetype_id: @format.archetypes.pluck(:id))
  end

  def decks
    @decks = @format.decks.includes({deck_list:  :archetype}, :author).active.legal.order("decks.created_at desc").where(public: true).page(params[:page]).per(6)
  end

  def editions
    @editions = @format.editions
  end

  def restricted_cards
    @restricted_cards = @format.restricted_cards.joins(:card).order("cards.name")
  end

  def diff
    @format_left  = Format.find(params[:left_id])
    @format_right = Format.find(params[:right_id])
    @left_only_cards= Card.where(id: Card.card_ids_at(@format_left.legalities.to_i & ~@format_right.legalities.to_i))
    @right_only_cards= Card.where(id: Card.card_ids_at(@format_right.legalities.to_i & ~@format_left.legalities.to_i))
  end

  def top_ratings_chart_data
    require 'whr_calculator'

    duel_ids = @format.duels.finished.select(:id)
    game_scope = Game.where("duel_id in (#{duel_ids.to_sql})")
    games = game_scope.select(:id, :losing_deck_list_id, :winning_deck_list_id, :created_at)
    whr_calc = WhrCalculator.new
    whr_calc.load games
    whr_calc.run

    @top_decks = Rating.highest_in(@format).limit(20).map {|rating| rating.deck_list}
    data = @top_decks.map{|deck|
      whr_data = whr_calc.ratings_for(deck.id.to_s)
      {
          name: deck.to_s,
          data: whr_data
          # Hash[(0..5).map{|n| n.days.ago}.reverse.map{|day|
          #   [day.strftime("%Y-%m-%d"), (r = deck.rating_in(@format)) && (Date.current == day.to_date ? r : r.paper_trail.version_at(day)).to_s.to_i || 0]}
          # ]
      }
    }
    render json: data
  end

  private
  def set_record
    @format = Format.where(name: params[:id]).first || Format.find(params[:id])
  end
end
