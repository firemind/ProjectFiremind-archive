class DeckEntryClustersController < ApplicationController

  def addto
    @deck_entry_cluster = DeckEntryCluster.find params[:deck_entry_cluster_id]
    @deck_entry = DeckEntry.find  params[:deck_entry_id]
    unless @deck_entry_cluster.deck_entries.include? @deck_entry
      @deck_entry_cluster.deck_entries << @deck_entry
      head 200, content_type: "text/html"
    else
      head 422, content_type: "text/html"
    end
  end

  def delfrom
    @deck_entry_cluster = DeckEntryCluster.find params[:deck_entry_cluster_id]
    @deck_entry = DeckEntry.find  params[:deck_entry_id]
    @deck_entry_cluster.deck_entries.delete(@deck_entry)
    head 200, content_type: "text/html"
  end

  def show
    @deck_entry_cluster = DeckEntryCluster.find params[:id]
    @cardtotal = @deck_entry_cluster.deck_entries.sum(:amount)
    @decksize = @deck_entry_cluster.deck.card_count
    render layout: nil
  end

  def new
    @deck_entry_cluster = DeckEntryCluster.new
    @deck_entry_cluster.deck = Deck.find(params[:deck_id])

    render layout: nil
  end

  def assign
    @deck = Deck.find(params[:deck_id])

    render layout: nil
  end

  def playable_hand
    @deck = Deck.find(params[:deck_id])
    @deck.deck_entry_clusters.each do |clu|
      phe = @deck.playable_hand_entries.where(deck_entry_cluster_id: clu.id).first

      unless phe
        @deck.playable_hand_entries.create!(deck_entry_cluster_id: clu.id, min_amount: 0, max_amount: 0)
      end
    end

    render layout: nil
  end

  def create
    @deck_entry_cluster = DeckEntryCluster.new(deck_entry_cluster_params)

    respond_to do |format|
      if @deck_entry_cluster.save
        format.html { redirect_to @deck_entry_cluster.deck, notice: 'Cluster was successfully created.' }
      else
        format.html { render 'new' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def deck_entry_cluster_params
    params.require(:deck_entry_cluster).permit(:name, :deck_id)
  end

end
