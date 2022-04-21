class AddIndexForHumanArchetypesToDeckLists < ActiveRecord::Migration
  def change
    add_index "deck_lists", ["human_archetype_id"]
  end
end
