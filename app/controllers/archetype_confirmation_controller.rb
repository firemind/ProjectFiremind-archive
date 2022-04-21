class ArchetypeConfirmationController < ApplicationController
  before_action :authenticate_admin!

  def index
    at_scope =  Archetype.where(format_id: Format.enabled.pluck(:id)).joins("INNER JOIN `deck_lists` ON (`deck_lists`.`archetype_id` = `archetypes`.`id` and deck_lists.human_archetype_id is null)").joins(:human_deck_lists).order("count(human_deck_lists_archetypes.id), rand()").group("archetypes.id").having("count(deck_lists.id) > 0")
    @archetype = at_scope.first
    @deck_list = DeckList.where(human_archetype_id: nil, archetype_id: @archetype.id).order("archetype_score desc").first
  end

  def confirm
    @deck_list = DeckList.find(params[:id])
    @deck_list.human_archetype_id = @deck_list.archetype_id
    @deck_list.human_archetype_confirmed=true
    @deck_list.save!
    redirect_to archetype_confirmation_index_path
  end
end
