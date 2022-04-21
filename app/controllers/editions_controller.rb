class EditionsController < ApplicationController
  def index
    scope = Edition.all
    @editions = if params[:by_implemented]
      scope.sort_by {|edition|
        edition.card_prints.count > 0 ? edition.card_prints.implemented.count.to_f / edition.card_prints.count : 0
      }.reverse
    else
      scope.order("release_date desc").all
    end

    respond_to do |format|
      format.html
      format.json { render :json => {records: @editions} }
    end
  end

  def show
    scope = Edition
    @edition = scope.where(short: params[:id]).first || scope.find(params[:id])
    @cards = @edition.card_prints.includes(:card).order("cards.name")
  end

  def visual
    @edition = Edition.includes(card_prints: :card).find params[:id]
  end

  def cards
    @edition = Edition.find_by_short(params[:set_code])
    respond_to do |format|
      format.json { render :json => {cards: @edition.cards.group("name")} }
    end
  end
end
