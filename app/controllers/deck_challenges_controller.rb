class DeckChallengesController < ApplicationController 
  before_action :set_deck_challenge, only: [:show, :challenger_select, :close]
  before_action :authenticate_user!, only: [:challenger_select]
  before_action :set_personal_deck_challenge, only: [:close, :run_more]
  
  def show
    @duels = @deck_challenge.duels.where(state: [:waiting, :started])

    @own_entry = @deck_challenge.challenge_entries.where(user_id: current_user.id).first if current_user
  end

  def challenger_select
    @decks = current_user.decks.where(format_id: @deck_challenge.format_id).joins(:deck_list).where(deck_lists: {enabled: true})
    @challenge_entry = ChallengeEntry.new
    @challenge_entry.deck_challenge_id = @deck_challenge.id

    render layout: nil
  end

  def new
    @deck_challenge = DeckChallenge.new
    @deck_challenge.deck_list = DeckList.find params[:deck_list_id]
    set_collections
  end

  def create
    @deck_challenge = DeckChallenge.new(deck_challenge_params)
    @deck_challenge.user = current_user
    @deck_challenge.duel_queue = DuelQueue.new(
          name: "Challenge Queue",
          active: true,
          magarena_version_major: CURRENT_MAGARENA_VERSION.split('.')[0],
          magarena_version_minor: CURRENT_MAGARENA_VERSION.split('.')[1],
          ai1: "MCTS",
          ai2: "MCTS",
          ai1_strength: 8,
          ai2_strength: 8,
          life: 20
    )

    respond_to do |format|
      if @deck_challenge.save
        format.html { redirect_to @deck_challenge, notice: 'Deck Challenge was successfully created.' }
        format.json { render action: 'show', status: :created, location: @deck_challenge }
      else
        set_collections
        format.html { render action: 'new' }
        format.json { render json: @deck_challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  def close

    respond_to do |format|
      if !@deck_challenge.duels_run?
        format.html { redirect_to @deck_challenge, notice: 'Deck Challenge can not be closed because there are still unfinished duels.' }
      elsif @deck_challenge.draw?
        format.html { redirect_to @deck_challenge, notice: 'Deck Challenge is currently in a draw so no winner can be chosen.' }
      else
        @deck_challenge.winner = @deck_challenge.current_leader
        if @deck_challenge.save
          format.html { redirect_to @deck_challenge, notice: 'Deck Challenge was successfully closed.' }
        else
          format.html { redirect_to @deck_challenge, notice: 'Problem closing Deck Challenge' }
        end
      end
    end
  end

  def run_more
    respond_to do |format|
      if @deck_challenge.draw?
        @deck_challenge.current_leaders.each do |entry|
          entry.create_duel
        end
        format.html { redirect_to @deck_challenge, notice: 'Additional Duels created.' }
      else
        format.html { redirect_to @deck_challenge, notice: 'Deck Challenge is not in a draw so there is no need to run more duels.' }
      end
    end
  end

  private

  def set_collections
    @formats = @deck_challenge.deck_list.formats.order("enabled desc")

  end

  def set_deck_challenge
    @deck_challenge = DeckChallenge.find params[:id]
  end

  def set_personal_deck_challenge
    @deck_challenge = current_user.deck_challenges.find params[:id]
  end

  def deck_challenge_params
    params.require(:deck_challenge).permit(:deck_list_id, :format_id, :description)
  end

end
