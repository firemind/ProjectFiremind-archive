class DecksController < ApplicationController
  include Sideboardable
  helper DecksHelper
  before_action :authenticate_user!, only: [:my, :new, :edit,  :my_forks, :destroy, :copy_sideboard_plan, :sideboarding]
  before_action :set_deck, only: [:show, :destroy, :duels, :format, :diff,  :follow, :unfollow, :embed, :destroy, :mulligans]
  before_action :set_personal_deck, only: [:edit, :add_sideboard_plan, :remove_sideboard_plan, :calculate_sideboard, :copy_sideboard_plan, :sideboarding, :sideboarding_suggestions, :update_thumb]

  # GET /decks
  # GET /decks.json
  def index
    @archetype = Archetype.find(params[:archetype_id])
    @decks = @archetype.decks.active.includes :author, deck_list: :archetype
  end

  def my
    @deck_sorting_options = [
        ["sort by name", :title],
        ["sort by last change", :updated_at],
        # ["sort by last duel", :last_duel],
        ["sort by rating", :rating]
    ]
    @sorting_selection = if params[:sort_by] && @deck_sorting_options.map(&:last).include?(v=params[:sort_by].to_sym)
      v
    else
      @deck_sorting_options.first.last
    end
    @formats_with_count = Format.enabled.map {|f|
      [f.name, current_user.decks.joins(:format).where(formats: {name: f.name.downcase}).count]
    }
    @formats_with_count << ["All", current_user.decks.count]
    @decks = current_user.decks.includes([{deck_list: :archetype},:author, thumb_print: :edition]).page(params[:page]).per(6)

    unless params[:deck_format] == "all"
      format = Format.where(name: params[:deck_format]).first
      @formatname = format.name
      @decks = @decks.where(format_id: format.id)
    else
      @formatname = "All"
    end
    unless (@search = params[:search]).blank?
      @decks = @decks.where("title like ?", "%#{@search}%")
    end
    @decks = case @sorting_selection
    # when :last_duel
    #    @decks.order_by_last_duel
    when :rating
      @decks.order_by_rating
    else
      @decks.order(@sorting_selection)
    end
  end

  def generate
    @format = Format.where(name: params[:format_name]).first!
    @colors = COLORS.sample 2
    @deck = Deck.new
    @deck.title = "Generic #{@colors.join('/')}"
    basics = 24
    entries = []
    cards = @format.legal_cards.enabled
    count = 60 - basics
    added = [0]
    @colors.each do |c| 
      entries << "#{basics / @colors.size} #{BASIC_LANDS_BY_COLOR[c.to_sym]}"
    end
    while(count > 0)
      card = cards.where(color: @colors.sample).order("RAND()").where("cards.id not in (?)", added).first
      added << card.id
      if count > 4
        amount = rand(3)+1
        count -= amount
      else
        amount = count
        count = 0
      end
      entries <<  "#{amount} #{card}"
    end
    @deck.decklist = entries.join("\n")
    @deck.format = @format
    @formats = [@format]
    render action: 'new'
  end

  def generate_from_archetype
    @archetype = Archetype.find(params[:archetype_id])
    @deck = Deck.new
    @deck.title = "Generic #{@archetype} for Magarena"
    @deck.format = @archetype.format
    @formats = [@deck.format]
    land_entries = []
    non_land_entries = []

    deck_entries = DeckEntry.joins(:deck_list, :card).where(deck_lists: {archetype_id: @archetype.id}, cards: {enabled: true}).select("card_id, sum(amount) as copy_count, count(deck_list_id) as dl_count").group("card_id")
    lc_query = DeckEntry.joins(:deck_list).where(group_type: :lands, deck_lists: {archetype_id: @archetype.id}).select("sum(amount) / count(distinct(deck_list_id)) as land_count").first
    lands_to_add = lc_query.land_count&.round || 0
    non_lands_to_add = 60-lands_to_add

    deck_lists = @archetype.deck_lists
    dl_count = deck_lists.count
    @cards = deck_entries.sort_by(&:copy_count).reverse.map {|de|
      break if (lands_to_add + non_lands_to_add) <=0
      number_of_copies_per_deck = de.copy_count.to_f / de.dl_count
      if de.card.land?
        amount = [lands_to_add, number_of_copies_per_deck.ceil].min
        next if amount < 1
        lands_to_add -= amount
        land_entries << {amount: amount, card: de.card}
      else
        amount = [non_lands_to_add, number_of_copies_per_deck.ceil].min
        next if amount < 1
        non_lands_to_add -= amount
        non_land_entries << {amount: amount, card: de.card}
      end
    }
    if non_land_entries.size > 0
      while(non_lands_to_add > 0)
        unless non_land_entries.select {|r| r[:amount] < 4}.any?
          lands_to_add += non_lands_to_add
          break
        end
        e = non_land_entries.sample
        if e[:amount] < 4
          e[:amount] += 1
          non_lands_to_add -= 1
        end
      end
    end
    if land_entries.size > 0
      while(lands_to_add > 0)
        e = land_entries.sample
        if e[:amount] < (e[:card].basic? ? 25 : 4)
          e[:amount] += 1
          lands_to_add -= 1
        end
      end
    end
    @deck.decklist = (land_entries|non_land_entries).map{|e| "#{e[:amount]} #{e[:card]}"}.join("\n")
    render action: 'new'
  end

  def sideboarding
    unless (@meta_id = params[:meta_id]).blank?
      @archetype_scope = Meta.find(@meta_id).meta_fragments.order("occurances desc").includes(archetype: {thumb_print: :edition}).map &:archetype
    else
      @archetype_scope = @deck.format.archetypes.includes(thumb_print: :edition)
    end
    set_sideboarding_vars
    @metas = @deck.format.meta.where(user_id: [current_user.id, nil])
    @best_sideboard_suggestions = @deck.sideboard_suggestions.where(deck_list_id: @deck.deck_list.id).includes(:meta).order(:score).group_by(&:meta_id).map{|k,v| v.first}
    @previous_versions_with_plans = DeckList.where(id: SideboardPlan.where(deck_id: @deck.id).where.not(deck_list_id: @deck.deck_list_id).pluck(:deck_list_id)).map{|dl| [dl, {
      ins: dl.sideboard_plans.to_a.sum{|sp| sp.sideboard_ins.count }, 
      outs: dl.sideboard_plans.to_a.sum{|sp| sp.sideboard_outs.count }
    }]}.to_h
    @out_options = @deck.deck_list.deck_entries.includes(:card).group_by(&:group_type).map do |k,v| 
      [k, v.sort_by{|r| r.card.name}.map{|r| 
        ["#{r.card} (#{r.amount})",r.card.name ]
      }]
    end
  end

  def sideboarding_suggestions
    @archetype = Archetype.find params[:archetype_id]
    others = SideboardPlan.where("deck_list_id in (#{@deck.deck_list.archetype.deck_lists.select(:id).to_sql})").includes({sideboard_ins: [:card], sideboard_outs: [:card]}).where(archetype_id: @archetype.id)
    from_sideboard_ins = SideboardEntry.joins(deck: :deck_list).group(:card_id).order("count(sideboard_entries.id) desc").select("card_id").preload(:card).where(deck_lists: {human_archetype_id: @deck.deck_list.archetype.id}).map &:card
    @suggestions = others.map{|sp| sp.sideboard_ins.map(&:card)}.flatten.uniq | (from_sideboard_ins||[])
    if plan= @deck.sideboard_plans.where(deck_list_id: @deck.deck_list_id).where(archetype_id: @archetype.id).first
      @suggestions -=  plan.sideboard_ins.map(&:card)
    end
  end

  def mulligans
    @hands = @deck.deck_list.dealt_hands.map do |hand|
      if hand.mulligan_decisions.any?
        res_draw  = hand.mulligan_decisions.where(draw: true).select("sum(mulligan) as mulls, count(id) as count").first
        res_play = hand.mulligan_decisions.where(draw: false).select("sum(mulligan) as mulls, count(id) as count").first
        record = {
          id: hand.id, 
          name: "Hand #{hand.id}",
          avg_draw: res_draw.count > 0 ? res_draw.mulls.to_f / res_draw.count.to_f : nil,
          avg_play: res_play.count > 0 ? res_play.mulls.to_f / res_play.count.to_f : nil
        }

        if current_user
          res_draw_me = hand.mulligan_decisions.where(draw: true).where(user_id: current_user.id).select("sum(mulligan) as mulls, count(id) as count").first
          res_play_me = hand.mulligan_decisions.where(draw: false).where(user_id: current_user.id).select("sum(mulligan) as mulls, count(id) as count").first
          record[:avg_draw_me] = res_draw_me.count > 0 ? res_draw_me.mulls.to_f / res_draw_me.count.to_f : nil
          record[:avg_play_me] = res_play_me.count > 0 ? res_play_me.mulls.to_f / res_play_me.count.to_f : nil
        end
        record
      end
    end.compact
  end


  def copy_sideboard_plan
    dl = DeckList.find params[:deck_list_id]
    @plans_to_copy = @deck.sideboard_plans.where(deck_list_id: dl.id)
    @deck.sideboard_plans.where(deck_list_id: @deck.deck_list_id).destroy_all
    @plans_to_copy.each do |plan|
      new_plan = plan.dup
      new_plan.deck_list_id = @deck.deck_list_id
      new_plan.save
      new_plan.sideboard_ins = plan.sideboard_ins.map &:dup
      new_outs = plan.sideboard_outs.map &:dup
      new_outs.each do |no|
        de = @deck.deck_list.deck_entries.where(card_id: no.card_id).first
        if de
          no.amount = [no.amount, de.amount].min
        else
          new_outs -= [no]
        end
      end
      new_plan.sideboard_outs = new_outs
      new_plan.save
    end
    redirect_to sideboarding_deck_path(@deck)
  end

  def add_sideboard_plan
    card = Card.find_by_name(params[:card_name])
    @archetype = Archetype.find params[:archetype_id]
    deck_list = @deck.deck_list
    sp = SideboardPlan.where(
      archetype: @archetype,
      deck_list: deck_list,
      deck: @deck
    ).first_or_create!
    sideboard_change =  (params[:operation] == 'out' ? sp.sideboard_outs : sp.sideboard_ins).where(card: card).first_or_initialize
    sideboard_change.amount = params[:amount]
    sideboard_change.save
    @deck.sideboard_suggestions.destroy_all
    set_sideboarding_vars
    respond_to do |format|
      format.js { render "sideboarding_update" }
    end
  end

  def update_sideboard_plan
    sideboard_change =  (params[:operation] == 'out' ? SideboardOut : SideboardIn).find params[:operation_id]
    @deck = sideboard_change.sideboard_plan.deck
    if @deck.author == current_user
      sideboard_change.amount = params[:amount]
      unless sideboard_change.save
        sideboard_change.errors.full_messages.each do |m|
          flash[:alert] = m
        end
      end
      @archetype = sideboard_change.sideboard_plan.archetype
      set_sideboarding_vars
      respond_to do |format|
        format.js { render "sideboarding_update" }
      end
    end
  end

  def remove_sideboard_plan
    sideboard_change =  (params[:operation] == 'out' ? SideboardOut : SideboardIn).find params[:operation_id]
    @deck = sideboard_change.sideboard_plan.deck
    if @deck.author == current_user
      @archetype = sideboard_change.sideboard_plan.archetype
      sideboard_change.destroy
      @deck.sideboard_suggestions.destroy_all
      set_sideboarding_vars
      respond_to do |format|
        format.js { render "sideboarding_update" }
      end
    end
  end

  def diff
    @other_deck = DeckList.find(params[:other_deck_id])
  end

  def top
    formats = [:standard, :modern, :legacy, :vintage, :pauper]
    #@standard_decks = DeckList.where(id: Rating.highest_in(Format.standard).limit(9).pluck(:deck_list_id))
    #@modern_decks = Rating.highest_in(Format.modern).limit(9).map &:deck_list
    #@legacy_decks = Rating.highest_in(Format.legacy).limit(9).map &:deck_list
    #@vintage_decks = Rating.highest_in(Format.vintage).limit(9).map &:deck_list
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", :layout => false, status: 404}
      format.json do
        render json: formats.map{|f|
          [f, DeckList.where(id: Rating.highest_in(Format.send(f)).limit(9).pluck(:deck_list_id)).includes(:archetype, :ratings, decks: :author, deck_entries: :card).each_with_object({}) {|d, h|
            h[d.to_s] = d.as_magarena_json
          }]
        }.to_h
      end
    end
  end

  # GET /decks/1
  # GET /decks/1.json
  def show
    if current_user && current_user == @deck.author && current_user.decks.where(deck_list_id: @deck.deck_list_id).size > 1
      redirect_to deck_list_path(@deck.deck_list, deck_id: @deck.id)
    else
      redirect_to deck_list_path(@deck.deck_list)
    end
  end

  def embed
    respond_to do |format|
      format.html do
        render layout: 'embedded'
        response.headers.delete('X-Frame-Options')
      end
    end
  end

  # GET /decks/new
  def new
    set_collections
    @deck = Deck.new
    if n = params[:formatname]
      @deck.format = Format.where(name: n).first
    end
  end

  # GET /decks/1/edit
  def edit
    set_collections
  end

  def format
    @format = Format.find(params[:format_id])

    if !@deck.deck_list.legal_in?(@format)
      @problems = []
      FormatCalcWorker.new.process_dl(@deck.deck_list, capture_errors: @problems, formats: [@format.id])
      @legal = @deck.deck_list.legal_in?(@format)
    else
      @legal = true
    end

    render layout: nil
  end

  # POST /decks
  # POST /decks.json
  def create
    @deck = Deck.new(deck_params)
    @deck.author = current_user
    if file_data = params[:deck][:decklist_file]
      if file_data.respond_to?(:read)
        @deck.decklist = file_data.read
      end
    end

    respond_to do |format|
      if @deck.save
        format.html { redirect_to @deck, notice: 'Deck was successfully created.' }
        format.json { render action: 'show', status: :created, location: @deck }
      else
        set_collections
        format.html { render action: 'new' }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /decks/1
  # PATCH/PUT /decks/1.json
  def update
    @deck = current_user.decks.find(params[:id])

    respond_to do |format|
      if file_data = params[:deck][:decklist_file]
        if file_data.respond_to?(:read)
          params[:deck][:decklist] = file_data.read
        end
      end
      if @deck.update(deck_params)
        format.html { redirect_to @deck, notice: 'Deck was successfully updated.' }
        format.json { head :no_content }
      else
        set_collections
        format.html { render action: 'edit' }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_thumb
    thumb = CardPrint.with_thumb.find(params[:thumb_id])
    if @deck.thumb_print_options.include? thumb
      @deck.thumb_print = thumb
      @deck.save
    end
    redirect_back(fallback_location: @deck)
  end

  # DELETE /decks/1
  # DELETE /decks/1.json
  def destroy

    respond_to do |format|
      unless current_user == @deck.author
        redirect_to @deck, alert: 'This is not your deck.'
        return
      end
      @deck.destroy
      format.html { redirect_to my_decks_url, notice: "Deleted deck #{@deck}" }
    end
  end


  def search
    if Rails.env.production? && !params[:query].blank?
      Rails.logger.notify! short_message: "Decks#search", :_deck_search => params[:query], :_user => current_user.to_s
    end
    @searcher = DeckSearcher.new(params[:query])
    @decks = @searcher.query.first(30)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          decks: @decks
        }
      end
    end
  end

  def search_suggestions
    @searcher = DeckSearcher.new(params.permit(:term)[:term])

    render json: @searcher.suggestions
  end

  def calculate_sideboard
    GeneticSideboardWorker.perform_async(@deck.id, Meta.where(id: params[:meta]).first&.id)
    redirect_to sideboarding_deck_path(@deck), notice: 'Started sideboarding calculation asynchronously. This will take a couple of seconds. Reload this page if necessary.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_deck
    @deck = Deck.includes(:deck_list).find(params[:id])
  end

  def set_personal_deck
    @deck = current_user.decks.find(params[:id])
  end

  def set_collections
    @formats = Format.enabled
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def deck_params
    params.require(:deck).permit(:title, :description, :author_id, :decklist, :avatar, :format_id, playable_hand_entries_attributes: [:max_amount, :min_amount, :id])
  end

end
