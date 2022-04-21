module Sideboardable
  extend ActiveSupport::Concern
     
  included do

    protected
    def set_sideboarding_vars
      if @deck.deck_list.archetype
        @others_map = SideboardPlan.where("deck_list_id in (#{@deck.deck_list.archetype.deck_lists.select(:id).to_sql})").includes({sideboard_outs: [:card], sideboard_ins: [:card]}).group_by(&:archetype_id).to_h
      else
        @others_map = []
      end
      plans_scope = @deck.sideboard_plans.where(deck_list_id: @deck.deck_list_id).includes(sideboard_outs: :card)
      if @archetype
        plans_scope.where(archetype_id: @archetype.id)
      end
      @plans_map = plans_scope.group_by(&:archetype_id).to_h
      @plans_by_archetype = (@archetype_scope||[@archetype]).map do |at| 
        others = @others_map[at.id] || []
        plan = @plans_map[at.id]&.first
        suggested_outs = others.map{|sp| sp.sideboard_outs.map(&:card)}.flatten.uniq
        if plan
          suggested_outs -=  plan.sideboard_outs.map(&:card)
        end
        [at, {
          plan: plan,
          suggested_outs: suggested_outs
        }]
      end.to_h
      if @archetype
        @data = @plans_by_archetype.first[1]
      end
      if session[:copied_plan] && session[:copied_plan][:deck_id] == @deck.id 
        @copied_archetype = Archetype.find(session[:copied_plan][:archetype_id])
      end
    end
  end
end
