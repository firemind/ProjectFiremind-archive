class AddArchetypeScoreToDeckLists < ActiveRecord::Migration
  def change
    add_column :deck_lists, :archetype_score, :float, null: false, default: 0.0
  end
end
