class AddHumanArchetypeIdToDeckLists < ActiveRecord::Migration
  def change
    add_column :deck_lists, :human_archetype_id, :integer
  end
end
