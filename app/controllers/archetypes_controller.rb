class ArchetypesController < ApplicationController
  before_action :authenticate_admin!, only: [:compare, :reassign, :merge]
  def index
    @format = Format.where(name: params[:format_id]).first!
    @archetypes = @format.archetypes.order_by_highest_rating_in(@format).page(params[:page]).per(12)
    unless (@search = params[:search]).blank?
      @archetypes = @archetypes.where("name like ? or archetypes.id in (?)", "%#{@search}%", ArchetypeAlias.where("name like ?", "%#{@search}%").pluck(:id))
    end
  end

  def decklists
    @deck_lists = DeckList.where.not(human_archetype_id: nil)
    respond_to do |format|
      format.csv { send_data @deck_lists.to_csv }
    end
  end

  def deck_lists_by_card
    @archetype = Archetype.find params[:id]
    @card = Card.find params[:card_id]
    @deck_lists = @archetype.deck_lists.containing_card(@card.id)
  end

  def classify
    @deck = Deck.new
    set_collections
  end

  def compare
    @left = Archetype.find params[:left_id]
    @right = Archetype.find params[:right_id]
    deck_entries_left = DeckEntry.joins(:deck_list).where(deck_lists: {human_archetype_id: @left.id}).select("card_id, card_id as id, sum(amount) as copy_count, count(deck_list_id) as dl_count").group("card_id").includes(:card)
    deck_entries_right = DeckEntry.joins(:deck_list).where(deck_lists: {human_archetype_id: @right.id}).select("card_id, card_id as id, sum(amount) as copy_count, count(deck_list_id) as dl_count").group("card_id").includes(:card)

    dl_count_left = @left.human_deck_lists.count
    dl_count_right = @right.human_deck_lists.count

    left_only = deck_entries_left - deck_entries_right
    right_only = deck_entries_right - deck_entries_left
    both = deck_entries_left & deck_entries_right

    @left_only_cards = left_only.sort_by(&:copy_count).map {|de|
      [de.card, {
        number_of_copies: de.copy_count,
        number_of_copies_per_deck: de.copy_count.to_f / de.dl_count,
        percent_of_decks: de.dl_count.to_f * 100 / (dl_count_left+0.000001)
      }]
    }.reverse

    @both_cards = both.sort_by(&:copy_count).map {|de|
      [de.card, {
        number_of_copies: de.copy_count,
        number_of_copies_per_deck: de.copy_count.to_f / de.dl_count
      }]
    }.reverse

    @right_only_cards = right_only.sort_by(&:copy_count).map {|de|
      [de.card, {
        number_of_copies: de.copy_count,
        number_of_copies_per_deck: de.copy_count.to_f / de.dl_count,
        percent_of_decks: de.dl_count.to_f * 100 / (dl_count_right+0.000001)
      }]
    }.reverse

  end

  def merge
    @from = Archetype.find(params[:from_id])
    @to   = Archetype.find(params[:to_id])

    ActiveRecord::Base.transaction do
      @from.merge_into @to
    end

    redirect_to @to
  end

  def compare_select
    @left = Archetype.find(params[:id])
    @archetypes = @left.format.archetypes
  end

  def reassign
    @from = Archetype.find(params[:from_id])
    @to   = Archetype.find(params[:to_id])
    @containing   = Card.find(params[:containing_id])
    DeckList.where("id in (#{DeckEntry.where(card_id: @containing.id).select(:deck_list_id).to_sql})").where(human_archetype_id: @from.id).update_all(human_archetype_id: @to.id)
    Misclassification.where(expected: @to.id, predicted: @from.id).destroy_all
    Misclassification.where(expected: @from.id, predicted: @to.id).destroy_all
    redirect_back(fallback_location: root_path)
  end

  def classify_deck
    @deck = Deck.new(deck_params)
    @deck.author = User.get_sys_user
    @deck.public = false
    @deck.title = "classification deck"

    if file_data = params[:deck][:decklist_file]
      if file_data.respond_to?(:read)
        @deck.decklist = file_data.read
      end
    end
    respond_to do |format|
      if @deck.save
        begin
          client = TfArchetypeClient.new
          res = client.query([@deck.deck_list])[0]
          @at, val = res[:predicted], res[:score]
        rescue => e
          flash[:error] = "Error in classification"
          Rails.logger.error e.message
          e.backtrace.each { |line| Rails.logger.error line }
          raise e unless Rails.env.production?
        end

        old_deck = @deck
        @deck = Deck.new
        @deck.format_id = old_deck.format_id
        @deck.decklist = old_deck.decklist
        set_collections
        format.html { render action: 'classify' }
#        format.json { render action: 'show', status: :created, location: @deck }
      else
        set_collections
        format.html { render action: 'classify' }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @archetype = Archetype.includes(:format).find(params[:id])
    deck_entries = DeckEntry.joins(:deck_list).where(deck_lists: {archetype_id: @archetype.id}).select("card_id, sum(amount) as copy_count, count(deck_list_id) as dl_count").group("card_id").includes(:card)

    deck_lists = @archetype.deck_lists
    dl_count = deck_lists.count
    @cards = deck_entries.sort_by(&:copy_count).map {|de|
      [de.card, {
        number_of_copies: de.copy_count,
        number_of_copies_per_deck: de.copy_count.to_f / de.dl_count,
        percent_of_decks: de.dl_count.to_f * 100 / dl_count
      }]
    }.reverse

  end

  protected
  def deck_params
    params.require(:deck).permit(:decklist, :format_id)
  end

  def set_collections
    @formats = Format.enabled.to_a
  end
end
