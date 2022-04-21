class SideboardSuggestionsController < ApplicationController

  def show
    @sideboard_suggestion = SideboardSuggestion.includes(deck: :format).find params[:id]
    raise "Unauthorized" unless @sideboard_suggestion.deck.author == current_user

    @archetypes = @sideboard_suggestion.deck.format.archetypes.includes(thumb_print: :edition)
    
  end

  def copy
    session[:copied_plan] = params[:id]
  end

end
