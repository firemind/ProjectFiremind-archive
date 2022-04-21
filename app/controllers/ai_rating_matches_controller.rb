class AiRatingMatchesController < ApplicationController
  before_action :set_ai_rating_match, only: [:edit, :update, :destroy]
  before_action :airm_authorized, except: [:index]

  # GET /ai_rating_matches
  # GET /ai_rating_matches.json
  def index
    @ai_rating_matches = AiRatingMatch.all
  end

  # GET /ai_rating_matches/1
  # GET /ai_rating_matches/1.json
  def show
    @ai_rating_match = AiRatingMatch.includes(duel_queue: {duels: {deck_list1: :archetype, deck_list2: :archetype, format: []}}).find(params[:id])
  end

  def diff
    @ai_rating_match = AiRatingMatch.includes(duel_queue: {duels: {deck_list1: :archetype, deck_list2: :archetype, format: []}}).find(params[:id])
  end

  # GET /ai_rating_matches/new
  def new
    @ai_rating_match = AiRatingMatch.new
    @ai_rating_match.ai_strength ||= 8
    @ai_rating_match.ai2_identifier = "base"
    @ai_rating_match.git_branch ||= 'master'
  end

  def compare
    @name = params[:ai_name]
    @identifiers = AiRatingMatch.includes(duel_queue: {duels: {deck_list1: :archetype, deck_list2: :archetype, format: []}}).where(ai1_name: @name).map(&:ai1_identifier).uniq
#    @against = AiRatingMatch.where(ai1_name: @name).group_by {|r| "#{r.ai2_name}-#{r.ai2_identifier}-#{r.ai_strength}"}
  end

  def compare_by_identifier
    #@identifiers = AiRatingMatch.where(ai1_name: @name).sort_by{|r| "#{r.ai2_name}#{r.ai2_identifier}#{r.ai_strength}"}.group_by(&:ai1_identifier)
    @name = params[:ai_name]
    @idf = params[:identifier]
    @opponents = AiRatingMatch.by_ai_idf(@name, @idf).select("distinct(concat_ws(' ', ai2_name,ai2_identifier)) as t").map(&:t).uniq.map{|op|
      sop = op.split(' ')
      [op, AiRatingMatch.includes(duel_queue: {duels: {deck_list1: :archetype, deck_list2: :archetype, format: []}}).by_ai_vs_ai(@name, @idf, sop[0], sop[1..-1])]
    }
    @airm_decks =  AirmDeck.includes(deck_list1: :archetype, deck_list2: :archetype).all
    @results = @airm_decks.map do |airm_deck|
      [airm_deck.to_s, @opponents.map do |op, airms|
        airms.map do |airm|
          wins_as_d1 = airm.duels
            by_matchup(airm_deck.deck_list1_id, airm_deck.deck_list2_id).
            joins(:games).
            where(games: {winning_deck_list_id: airm_deck.deck_list1_id}).
            count("games.id")

          wins_as_d2 = airm.duels
            by_matchup(airm_deck.deck_list1_id, airm_deck.deck_list2_id).
            joins(:games).
            where(games: {winning_deck_list_id: airm_deck.deck_list2_id}).
            count("games.id")

          wins_as_d1 + wins_as_d2
        end.sum
      end]
    end
  end

  # POST /ai_rating_matches
  # POST /ai_rating_matches.json
  def create
    @ai_rating_match = AiRatingMatch.new(ai_rating_match_params)
    @ai_rating_match.owner = current_user


    respond_to do |format|
      AiRatingMatch.transaction do

        access_token = SecureRandom.hex
        queue = DuelQueue.create({
          name: "airm#{access_token}",
          access_token: access_token,
          active: true,
          magarena_version_major: DuelQueue.default.magarena_version_major,
          magarena_version_minor: DuelQueue.default.magarena_version_minor,
          ai1: @ai_rating_match.ai1_identifier,
          ai2: @ai_rating_match.ai2_identifier,
          ai1_strength: @ai_rating_match.ai_strength,
          ai2_strength: @ai_rating_match.ai_strength,
          life: 20,
        })
        @ai_rating_match.duel_queue = queue

        if @ai_rating_match.save
          queue.name= "airm#{@ai_rating_match.id}"
          queue.save!


          @ai_rating_match.iterations.times do |i|
            AirmDeck.all.each do |d|
              d.create_duels!(queue, i )
            end
          end
          @ai_rating_match.duel_queue = queue
          @ai_rating_match.save!
          @ai_rating_match.add_to_redis_queue
          format.html { redirect_to @ai_rating_match, notice: 'Ai rating match was successfully created.' }
        else
          format.html { render action: 'new' }
        end
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ai_rating_match
    @ai_rating_match = AiRatingMatch.find(params[:id])
  end

  def ai_rating_match_params
    params.require(:ai_rating_match).permit(:ai1_name, :ai2_name, :ai1_identifier, :ai2_identifier, :ai_strength, :git_repo, :git_branch, :iterations)
  end

  def airm_authorized
    unless current_user && current_user.airm_authorized?
      begin
        redirect_back fallback_location: root_path, error:  'Not authorized to access AIRM'
        rescue ActionController::RedirectBackError
          redirect_to root_path, error:  'Not authorized to access AIRM'
      end
    end
  end
end
