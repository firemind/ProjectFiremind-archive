class MaybeEntriesController < ApplicationController

  def new
    @deck = Deck.find(params[:deck_id])
    @maybe_entry = MaybeEntry.new
    @maybe_entry.deck = @deck

    @deck_entry_clusters = @deck.deck_entry_clusters

    render layout: nil
  end

  def edit
    @maybe_entry = MaybeEntry.find params[:id]
    @deck = @maybe_entry.deck

    @deck_entry_clusters = @deck.deck_entry_clusters

    render layout: nil
  end

  def create
    @maybe_entry = MaybeEntry.new(maybe_entry_params)

    respond_to do |format|
      if @maybe_entry.save
        format.html { redirect_to @maybe_entry.deck, notice: 'Maybe Entry was successfully created.' }
      else
        @deck = @maybe_entry.deck

        @deck_entry_clusters = @deck.deck_entry_clusters

        format.html { render 'new' }
      end
    end
  end

  def update
    @maybe_entry = MaybeEntry.find params[:id]

    respond_to do |format|
      if @maybe_entry.update(maybe_entry_params)
        format.html { redirect_to @maybe_entry.deck, notice: 'Maybe Entry was successfully updated.' }
      else
        @deck = @maybe_entry.deck

        @deck_entry_clusters = @deck.deck_entry_clusters

        format.html { render 'edit' }
        format.js   { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  def destroy
    @maybe_entry = MaybeEntry.find params[:id]
    @maybe_entry.destroy
    respond_to do |format|
      format.html { redirect_to @maybe_entry.deck }
      format.json { head :no_content }
    end
  end


  protected
  # Never trust parameters from the scary internet, only allow the white list through.
  def maybe_entry_params
    params.require(:maybe_entry).permit(:card_name, :deck_id, :deck_entry_cluster_id, :min_amount, :max_amount)
  end

end
