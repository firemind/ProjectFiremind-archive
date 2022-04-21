class AddHumanArchetypeConfirmedToDeckLists < ActiveRecord::Migration
  def change
    add_column :deck_lists, :human_archetype_confirmed, :boolean, default: false
  end
end
