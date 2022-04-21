class CardsController < ApplicationController
  before_action :authenticate_user!, only: :add_unimplementable_reasons
  def show
    scope = Card.includes(card_prints: :edition)
    @card =scope.find(params[:id])
    @top_ratings = Rails.cache.fetch([:card, params[:id], :top_ratings], expires_in: 4.hours ) do
      scope.find(params[:id]).ratings.includes(:format,deck_list: :archetype).order("whr_rating desc").limit(10)
    end
    deck_entries = @card.deck_entries.joins(:deck_list).
        select("deck_lists.archetype_id as at_id, sum(amount) as copy_count, count(deck_list_id) as dl_count").
        where.not(deck_lists: {archetype_id:nil}).group("deck_lists.archetype_id")

    dl_count = DeckList.select("archetype_id, count(deck_lists.id) as cnt").group("archetype_id").map{|r| [r.archetype_id, r.cnt]}.to_h
    @archetypes = deck_entries.sort_by(&:copy_count).map {|de|
      [Archetype.find(de.at_id), {
        number_of_copies: de.copy_count,
        number_of_copies_per_deck: de.copy_count.to_f / de.dl_count,
        percent_of_decks: de.dl_count.to_f * 100 / dl_count[de.at_id]
      }]
    }.reverse
    respond_to do |format|
      format.html
      format.json { render json: @card.as_json }
    end
  end

  def tooltip
    @card = Card.find(params[:id])
    render layout: false
  end

  def index
    @cards = Card.select("id, name, enabled").order(:name).where("name like ?", "#{params[:term]}%").limit(20)
    render json: @cards.map(&:name).uniq
  end

  def disabled
    @cards = Card.select("id, name, enabled").having(enabled: false).order(:name).where("name like ?", "#{params[:term]}%").limit(20)
    render json: @cards.map(&:name).uniq
  end

  def enabled
    @cards = Card.select("id, name, enabled").having(enabled: true).order(:name).where("name like ?", "#{params[:term]}%").limit(20)
    render json: @cards.map(&:name).uniq
  end

  def all
    @cards = Rails.cache.fetch([:all_cards], expires_in: 1.hour) do
      Card.select("id").all
    end
    render json: @cards.map(&:id)
  end

  def search
    if !params[:query].blank?
      if Rails.env.production?
        Rails.logger.notify! short_message: "Cards#search", :_card_search => params[:query], :_user => current_user.to_s
      end
      @query = sanitize_string_fulltext_search(params[:query])
      @cards = Card.full_text_search(@query)
    else
      @cards = Card.limit(10)
    end
    if @only_enabled = !!params[:only_enabled]
      @cards = @cards.where(enabled: true)
    end
  end

  def missing
    if !params[:query].blank?
      @query = sanitize_string_fulltext_search(params[:query])
      @cards = Card.full_text_search(@query)
    else
      @cards = Card.order("rand()").where(enabled: false).limit(10)
    end
    @cards = @cards.includes(:not_implementable_reasons)
    unless @show_unimplementable_cards = params[:show_unimplementable_cards]
      @cards = @cards.where("id not in (select card_id from cards_not_implementable_reasons)")
    end
    unless @show_upcoming_cards = params[:show_upcoming_cards]
      @cards = @cards.where(added_in_next_release: false)
    end
    unless @show_claimed_cards = params[:show_claimed_cards]
      @cards = @cards.where.not(id: CardScriptClaim.pluck(:card_id))
    end
  end

  def scripts
    @card = Card.find(params[:id])
  end

  def add_unimplementable_reasons
    @card = Card.find(params[:id])
    if params[:card] 
    reasons = NotImplementableReason.find(params[:card][:not_implementable_reason_ids])
    else
      reasons = []
    end
    @card.not_implementable_reasons = reasons
    @card.config_updater = current_user
    @card.save
    UpdateMissingCardTagsWorker.perform_async @card.id
    redirect_to @card
  end

end
