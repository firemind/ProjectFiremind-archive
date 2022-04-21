module SideboardSuggestionsHelper
  def take_out(deck, archetype, sideboard_suggestion)
    outs = []
    if sideboard_plan = deck.sideboard_plans.where(archetype_id: archetype.id).first
      sideboard_plan.sideboard_outs.includes(:card).each do |o|
        outs << [o.amount, o.card]
      end
    end
    outs
  end

  def bring_in(deck, archetype, sideboard_suggestion)
    ins = []
    if sideboard_plan = deck.sideboard_plans.where(archetype_id: archetype.id).first
      sideboard_suggestion.entries.each do |entry|
        if o = sideboard_plan.sideboard_ins.includes(:card).where(card_id: entry[1].id).first
          ins << [[o.amount, entry[0]].min, o.card]
        end
      end
    end
    ins 
  end
end
