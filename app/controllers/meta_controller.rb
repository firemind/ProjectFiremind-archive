class MetaController < ApplicationController

  def breakdown
    @meta = Meta.find(params[:id])
    @archetypes = @meta.archetypes
  end

  def my
    @format = Format.find(params[:format_id])
    @meta = current_user.meta.where(format_id: @format.id, name: "My #{@format} Meta").first_or_create

    set_at_ids = @meta.meta_fragments.includes(:archetype).map &:archetype_id
    @format.archetypes.each do |at|
      unless set_at_ids.include? at.id
        @meta.meta_fragments.build(:archetype_id => at.id, occurances: 0)
      end
    end
  end


  def update
    @meta = current_user.meta.find(params[:id])
    @meta.user = current_user
    
    respond_to do |format|
      if @meta.update(meta_params)
        format.html { redirect_to my_meta_index_path(format_id: @meta.format.id), notice: 'Meta was successfully updated.' }
      else
        format.html { render action: 'my' }
      end
    end
  end



  def run
    raise "refactor!"
    @meta = Meta.find(params[:id])

    decks = @meta.decks.sample(2)

    @duel = Duel.new
    @duel.format = @meta.format
    @duel.games_to_play = 5
    @duel.public = true
    @duel.user = current_user
    @duel.state = 'waiting'
    @duel.deck1 = decks[0]
    @duel.deck2 = decks[1]

    @duel.save!
    redirect_to @duel, notice: 'Duel was successfully created.'
  end

  private

  def meta_params
    params.require(:meta).permit(:format_id, :name, meta_fragments_attributes: [:archetype_id, :occurances, :id])
  end
end
