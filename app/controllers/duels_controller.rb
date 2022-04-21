class DuelsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :update, :edit, :my]
  before_action :set_duel, only: [:show, :edit, :update, :destroy, :box]
  before_action :set_collections, only: [:new, :create]

  # GET /duels
  # GET /duels.json
  def index
    if params[:deck_id]
      @deck = Deck.find params[:deck_id]
      @duels = Duel.visible_to(current_user).
        includes([:format, {deck_list1: :archetype}, {deck_list2: :archetype}]).
        where("deck_list1_id = ? or deck_list2_id = ?", @deck.deck_list_id, @deck.deck_list_id).
        page(params[:page])
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def my
    @state = params[:duel_state]
    @duels = current_user.duels.
      includes([:format, {deck_list1: :archetype}, {deck_list2: :archetype}]).
      order('updated_at desc').page(params[:page]).per(15)
  end

  # GET /duels/1
  # GET /duels/1.json
  def show
    @waiting_in_queue = DuelQueue.default.count
  end

  def box
    render partial: 'duel', locals: {duel: @duel}
  end

  # GET /duels/new
  def new
    @duel = Duel.new
    @duel.duel_queue = DuelQueue.default
    if params[:deck1_id]
      deck = Deck.find params[:deck1_id]
      @duel.deck_list1_id = deck.deck_list_id
      @duel.format = deck.format
      @formats = [deck.format]
    elsif  params[:deck_list1_id]
      deck_list = DeckList.find params[:deck_list1_id]
      @duel.deck_list1_id = deck_list.id
      @formats = deck_list.formats.enabled
      @duel.format = @formats.first
    end
  end

  def edit
  end

  # POST /duels
  # POST /duels.json
  def create
    @duel = Duel.new(duel_params)
    @duel.user = current_user
    @duel.state = 'waiting'

    if @duel.duel_queue != DuelQueue.default && @duel.duel_queue.user != current_user
      redirect_to @duel, error: 'No permission to create duel in that queue.'
      return
    end

    respond_to do |format|
      if @duel.save
        format.html { redirect_to @duel, notice: 'Duel was successfully created.' }
        format.json { render 'show', status: :created, location: @duel }
      else
        format.html { render 'new' }
        format.json { render json: @duel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /duels/1
  # PATCH/PUT /duels/1.json
  def update
    respond_to do |format|
      filtered_params = params.require(:duel).permit(:public)
      if @duel.update(filtered_params)
        format.html { redirect_to @duel, notice: 'Duel was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render 'edit' }
        format.json { render json: @duel.errors, status: :unprocessable_entity }
      end
    end
  end

  def challenge_top
    f = Format.find params[:format_id]
    d = Deck.find params[:deck_id]
    respond_to do |format|
      if d.enabled && d.deck_list.enabled?
        f.ratings.where.not(deck_list_id: d.deck_list_id).order('whr_rating desc').limit(10).each do |r|
          if current_user.queued_games_count < current_user.max_queued_games
            @duel = Duel.new_by_user(current_user, d.deck_list, r.deck_list, f)
            @duel.save!
          else
            format.html { redirect_to my_duels_path, flash: {error: 'You exceeded the number of queueable duels per user. Because of this not all duels could be created. Please come back once your queue has cleared.'} }
          end
        end
        format.html { redirect_to my_duels_path, notice: 'All duels have been successfully created.' }
      else
        format.html { redirect_to d, error: 'Deck is not enabled. No duels can be run.' }
      end
    end
  end

  # DELETE /duels/1
  # DELETE /duels/1.json
  #def destroy
    #@duel.destroy
    #respond_to do |format|
      #format.html { redirect_to duels_url }
      #format.json { head :no_content }
    #end
  #end

  def search_decks
    base_scope = Deck.active.visible_to(current_user).limit(10)
    if params[:format_id]
      base_scope = base_scope.where(format_id: params[:format_id])
    end
    if params[:query] && params[:query].size > 3
      @query = sanitize_string_fulltext_search(params[:query])
      @decks = base_scope.
          where("match(title) against (? IN NATURAL LANGUAGE MODE)", @query) |
        base_scope.joins(deck_list: :archetype).
            where("match(archetypes.name) against (? IN NATURAL LANGUAGE MODE)", @query)
      if params[:format_id]
        @decks = @decks.select{|d| d.deck_list.legal_in? Format.find(params[:format_id])}
      end
    else
      @decks = []
    end
    @decks = @decks.first(20)

    respond_to do |format|
      format.json do
        render 
      end
    end

  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_duel
      @duel = Duel.includes(deck_list1: [:archetype], deck_list2: [:archetype], games: [:winning_deck_list]).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def duel_params
      params.require(:duel).permit(:games_to_play, :deck_list1_id, :deck_list2_id, :public, :format_id, :duel_queue_id, :deck_challenge_id)
    end

    def set_collections
      @formats = Format.enabled
      @available_decks = @formats.map{ |format| [format.to_s, format.legal_decks.active.order("title").visible_to(current_user).includes(:author).map { |deck| [deck.title_and_author, deck.deck_list_id] }]}
    end
end
