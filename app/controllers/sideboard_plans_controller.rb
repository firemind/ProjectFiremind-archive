class SideboardPlansController < ApplicationController
  include Sideboardable
  def copy
    @archetype = Archetype.find params[:archetype_id]
    @deck = Deck.find params[:deck_id]
    session[:copied_plan] = {
      archetype_id: @archetype.id,
      deck_id: @deck.id,
      deck_list_id: @deck.deck_list_id,
    }

    set_sideboarding_vars
    respond_to do |format|
      format.js { render "decks/sideboarding_update" }
    end
  end

  def paste
    if session[:copied_plan] && session[:copied_plan][:archetype_id]
      @archetype = Archetype.find params[:archetype_id]
      @from_archetype = Archetype.find session[:copied_plan][:archetype_id]
      @deck = Deck.find session[:copied_plan][:deck_id]
      @deck_list = DeckList.find session[:copied_plan][:deck_list_id]
      @plans_to_copy = @deck.sideboard_plans.where(deck_list_id: @deck_list.id, archetype_id: @from_archetype.id)
      @deck.sideboard_plans.where(deck_list_id: @deck.deck_list_id, archetype_id: @archetype.id).destroy_all
      @plans_to_copy.each do |plan|
        new_plan = plan.dup
        new_plan.deck_list_id = @deck.deck_list_id
        new_plan.archetype = @archetype
        new_plan.save!
        new_plan.sideboard_ins = plan.sideboard_ins.map &:dup
        new_plan.sideboard_outs = plan.sideboard_outs.map &:dup
        new_plan.save!
      end
      set_sideboarding_vars
    else
      flash[:alert] = "Nothing copied!"
    end
    respond_to do |format|
      format.js { render "decks/sideboarding_update" }
    end
  end
end
