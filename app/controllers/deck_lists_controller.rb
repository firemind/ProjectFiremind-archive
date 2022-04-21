class DeckListsController < ApplicationController
  before_action :set_deck_list, only: [:show, :show_cards, :fetch_games, :fork, :change_archetype, :challenge_with, :update, :dealt_hands, :list, :tooltip, :follow, :unfollow, :ratings, :ratings_chart_data, :matchup]
  before_action :authenticate_user!, only: [:fork, :change_archetype, :update, :follow, :unfollow]
  helper DecksHelper

  def index
    @archetype = Archetype.find params[:archetype_id]
    @deck_lists = @archetype.deck_lists
  end

  def show
    respond_to do |format|
      format.html do
        if current_user
          scope = @deck_list.decks.where(author_id: current_user.id)
          @deck = params[:deck_id] ? scope.find(params[:deck_id]) : scope.first
        end
        @title = @deck ? @deck.title : @deck_list.to_s

        @running_duels = @deck_list.duels.unfinished.order("created_at desc").includes(:format, :user, deck_list1: {archetype: {thumb_print: :edition} }, deck_list2: {archetype: {thumb_print: :edition} }).first(5)
      end
      format.json {
        render json: @deck_list.as_magarena_json
      }
      format.dec { send_data @deck_list.as_text}
    end
  end

  def list
    respond_to do |format|
      format.html do
        render partial: 'deck_lists/decklist', locals: {deck: @deck_list}
      end
    end
  end

  def show_cards
    respond_to do |format|
      format.html do
        render layout: false
      end
    end
  end

  def fetch_games
    respond_to do |format|
      format.html { render layout: false}
    end
  end

  def fork
    @new_deck = @deck_list.decks.build
    @new_deck.title = @deck_list.to_s
    @new_deck.description = "Fork of #{@deck_list.to_s}"
    @new_deck.forked_from_id = @deck_list.id
    unless @deck_list.archetype
      AssignArchetypeWorker.new.perform(@deck_list.id)
    end
    @new_deck.format = @deck_list.archetype&.format || Format.vintage
    @new_deck.author = current_user
    respond_to do |format|
      if @new_deck.save
        format.html { redirect_to deck_path(@new_deck), notice: 'Deck was successfully forked.' }
      else
        format.html { redirect_to @deck_list, alert: 'Forking failed: '+@new_deck.errors.inspect }
      end
    end
  end

  def change_archetype
    set_format_and_archetype_selections
    respond_to do |format|
      format.html do
      end
    end
  end

  def dealt_hands
    @dealt_hands = @deck_list.dealt_hands
    respond_to do |format|
      format.html do
      end
    end
  end

  def tooltip
    render layout: false
  end

  def ratings
    @rating = @deck_list.ratings.find(params[:rating_id])
  end

  def ratings_chart_data
    require 'whr_calculator'
    @format = Format.find(params[:format_id])
    duel_ids = @format.duels.finished.select(:id)
    game_scope = Game.where("duel_id in (#{duel_ids.to_sql})")
    games = game_scope.select(:id, :losing_deck_list_id, :winning_deck_list_id, :created_at)
    whr_calc = WhrCalculator.new
    whr_calc.load games
    whr_calc.run

    whr_data = whr_calc.ratings_for(@deck_list.id.to_s)
    data = [
      {
          name: @deck_list.to_s,
          data: whr_data
          # Hash[(0..5).map{|n| n.days.ago}.reverse.map{|day|
          #   [day.strftime("%Y-%m-%d"), (r = deck.rating_in(@format)) && (Date.current == day.to_date ? r : r.paper_trail.version_at(day)).to_s.to_i || 0]}
          # ]
      }
    ]
    render json: data
  end

  def update

    if deck_list_params[:suggested_archetype_name].blank?
      archetype_id = deck_list_params[:archetype_id]
    else
      if current_admin
        archetype_id = Archetype.where(name: deck_list_params[:suggested_archetype_name], format_id: deck_list_params[:format_id]).first_or_create!.id
      else
        @deck_list.suggested_archetype_name = deck_list_params[:suggested_archetype_name]
        @deck_list.save
        SystemMailer.archetype_name_suggestion_email(@deck_list, current_user).deliver
        redirect_to @deck_list, notice: 'Suggestion successfully submitted.'
        return
      end
    end

    respond_to do |format|
      if !archetype_id.blank? && @deck_list.update(human_archetype_id: archetype_id, archetype_id: archetype_id)
        if current_admin
          @deck_list.human_archetype_confirmed = true
          @deck_list.save
        else
          SystemMailer.archetype_updated_email(@deck_list, current_user).deliver
        end
        format.html { redirect_to @deck_list, notice: 'Deck was successfully updated.' }
      else
        raise @deck_list.errors.inspect
        format.html { 
          set_format_and_archetype_selections
          render action: 'change_archetype' }
      end
    end

  end

  def challenge_with
    @formats = @deck_list.formats.enabled
    @decks = current_user ? current_user.decks.where(format_id: @formats.first.id).legal.active : []
    @duel = Duel.new
    @duel.duel_queue = DuelQueue.default
    @duel.deck_list1_id = @deck_list.id
    render layout: nil
  end

  def follow
    current_user.follow(@deck_list)
    redirect_to @deck_list, notice: "You are now following #{@deck_list}"
  end

  def unfollow
    current_user.stop_following(@deck_list)
    redirect_to @deck_list, notice: "You are no longer following #{@deck_list}"
  end

  def matchup
    @opposing_archetype = Archetype.find params[:archetype_id]
    @games = @deck_list.games_against_archetype(@opposing_archetype).order("created_at desc").page(params[:page]).per(15)
    respond_to do |format|
      format.html do
        @archetype = @deck_list.archetype
        @title = "Matchup of #{@deck_list} vs #{@opposing_archetype}"
        @win_count  = @deck_list.win_count_against_archetype(@opposing_archetype)
        @loss_count = @deck_list.loss_count_against_archetype(@opposing_archetype)
        @sum = (@loss_count+@win_count)
        @win_rate = @win_count.to_f / @sum
        @variance = @win_rate*(1.0-@win_rate)
        metric_select = %Q(
          avg(win_on_turn) as avg_turn,
          avg(winner_decision_count) as avg_winner_decisions,
          avg(winner_action_count) as avg_winner_actions,
          avg(loser_decision_count) as avg_loser_decisions,
          avg(loser_action_count) as avg_loser_actions,
          avg(play_time_sec) as avg_play_time,
          sum(if(deck_list_on_play_id = #{@deck_list.id},1,0))/sum(if(deck_list_on_play_id is NULL, 0, 1)) as on_play_perc
         )
        @win_metrics = @deck_list.won_games_against_archetype(@opposing_archetype).
            select(metric_select).first
        @loss_metrics = @deck_list.lost_games_against_archetype(@opposing_archetype).
            select(metric_select).first
      end
      format.js do
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_deck_list
    @deck_list = DeckList.find(params[:id])
  end

  def deck_list_params
    params.require(:deck_list).permit(:suggested_archetype_name, :archetype_id, :format_id)
  end

  def set_format_and_archetype_selections
    @formats = @deck_list.decks.map(&:format)
    if @formats.empty?
      @formats = @deck_list.formats
    end
    @archetypes = Archetype.where(format_id: @formats.map(&:id)).order("name")
  end

end
